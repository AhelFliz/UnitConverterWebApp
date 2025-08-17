class DashboardController < ApplicationController
  def index
    @type = params[:type]
    @amount_to_convert = params[:amount_to_convert]
    @unit_to_convert_from = params[:unit_to_convert_from]
    @unit_to_convert_to = params[:unit_to_convert_to]
    @units = define_units || []
    
    @result = calculate_result if conversion_ready?
  end

  private

  def calculate_result
    setup_conversions
    @type == 'temperature' ? convert_temperature : convert_meters_kgs
  end

  def conversion_ready?
    @type.present? && @amount_to_convert.present? && @unit_to_convert_from.present? && @unit_to_convert_to.present?
  end

  def convert_temperature
    celsius = case @unit_to_convert_from
    when 'celsius' then @amount_to_convert.to_f
    when 'fahrenheit' then (@amount_to_convert.to_f - 32) * 5.0 / 9.0
    when 'kelvin' then @amount_to_convert.to_f - 273.15
    end

    result = case @unit_to_convert_to
    when 'celsius' then celsius
    when 'fahrenheit' then (celsius.to_f * 9.0 / 5.0) + 32
    when 'kelvin' then celsius.to_f + 273.15
    end

    return result.round(2)
  end

  def convert_meters_kgs
    units = @conversions[@type.to_sym][:units]
    base_value = @amount_to_convert.to_f * units[@unit_to_convert_from]

    result = base_value / units[@unit_to_convert_to]
    return result&.round(4)
  end

  def setup_conversions
    @conversions = {
      length: {
        base: 'meters',
        units: {
          'meters' => 1.0,
          'cm' => 0.01,
          'feet' => 0.3048,
          'inches' => 0.0254
        }
      },
      weight: {
        base: 'kg',
        units: {
          'kg' => 1.0,
          'grams' => 0.001,
          'lbs' => 0.453592,
          'ounces' => 0.0283495
        }
      }
    }
  end

  def define_units
    case @type
    when 'length' then ['meters', 'feet', 'inches', 'cm']
    when 'weight' then ['kg', 'lbs', 'grams', 'ounces']
    when 'temperature' then ['celsius', 'fahrenheit', 'kelvin']
    else []
    end
  end
end
