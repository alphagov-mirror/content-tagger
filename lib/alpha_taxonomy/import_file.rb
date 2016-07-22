require "csv"

module AlphaTaxonomy
  class ImportFile
    include AlphaTaxonomy::Helpers::ImportFileHelper
    class BlankMappingFieldError < StandardError; end

    class_attribute :location
    self.location = begin
      FileUtils.mkdir_p Rails.root + "lib/data/"
      Rails.root + "lib/data/alpha_taxonomy_import.tsv"
    end

    def initialize(logger: Logger.new(STDOUT), sheet_identifiers:)
      @log = logger
      @sheet_identifiers = sheet_identifiers
    end

    def populate
      @file = File.new(self.class.location, "wb")
      write_headers

      SheetDownloader.new(logger: @log, sheet_identifiers: @sheet_identifiers).each_sheet do |taxonomy_data|
        write(taxonomy_data)
      end

      @file.close
    rescue => e
      log_failure(e)
      clean_up
    end

    def clean_up
      File.delete(@file.path) if File.exist?(@file.path)
    end

  private

    def write_headers
      @file.write("taxon_title\tbase_path\n")
    end

    def write(taxonomy_data)
      relevant_columns_in(taxonomy_data).each do |row|
        mapped_to = row[0]
        base_path = row[1]

        if mapped_to.blank? || base_path.blank?
          raise BlankMappingFieldError, "Missing value in downloaded taxonomy spreadsheet"
        end

        next if mapped_to[0..2] == "n/a"

        taxon_titles = derive_taxon_array_from(mapped_to)
        taxon_titles.each do |taxon_title|
          @file.write("#{taxon_title}\t#{base_path}\n")
        end
      end
    end

    def relevant_columns_in(taxonomy_data)
      tsv_data = CSV.parse(taxonomy_data, col_sep: "\t", headers: true)
      desired_columns = ["mapped to", "link"]
      columns_in_data = tsv_data.headers.select { |header| header.downcase.in? desired_columns }

      if columns_in_data.count == desired_columns.count
        tsv_data.values_at(*columns_in_data)
      else
        raise ArgumentError, "Column names in downloaded taxonomy data did not match expected values: #{desired_columns}"
      end
    end

    def log_failure(exception)
      @log.error "Failed to create import file"
      @log.error "Exception: #{exception}"
      @log.error exception.backtrace.join("\n").to_s
    end

    # We expect to receive a pipe-separated list.
    # Return an array of whitespace-stripped taxon titles, removing
    # any blank strings in the process.
    def derive_taxon_array_from(taxon_titles)
      taxon_titles.split('|').map(&:strip).reject(&:blank?)
    end
  end
end
