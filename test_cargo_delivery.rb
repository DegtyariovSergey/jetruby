require 'minitest/autorun'
require_relative 'C:\Users\серый\Desktop\Ruby\cargo_delivery' 

class CargoDeliveryTest < Minitest::Test
# Тест расчета объема
	def test_volume
		cargo = CargoDelivery.new(5.0, 100, 50, 50, 'Moscow', 'Saint Petersburg')
		expected_volume = 0.25 # 100 * 50 * 50 / 1_000_000 = 0.25 куб.м
		assert_equal expected_volume, cargo.volume
	end

# Тест расчета цены для груза объемом < 1 куб.м
	def test_calculate_price_small_cargo
		cargo = CargoDelivery.new(5.0, 100, 50, 50, 'Moscow', 'Saint Petersburg')
		cargo.instance_variable_set(:@distance, 700) # Явно задаем расстояние в 700 км
		assert_equal 700.0, cargo.calculate_price # Ожидаемая цена: 1 руб/км
	end

# Тест расчета цены для груза объемом > 1 куб.м и весом < 10 кг
	def test_calculate_price_large_light_cargo
		cargo = CargoDelivery.new(8.0, 200, 100, 50, 'Moscow', 'Saint Petersburg')
		cargo.instance_variable_set(:@distance, 700) # Явно задаем расстояние в 700 км
		assert_equal 1400.0, cargo.calculate_price # Ожидаемая цена: 2 руб/км
	end

# Тест расчета цены для груза объемом > 1 куб.м и весом > 10 кг
	def test_calculate_price_large_heavy_cargo
		cargo = CargoDelivery.new(15.0, 200, 100, 50, 'Moscow', 'Saint Petersburg')
		cargo.instance_variable_set(:@distance, 700) # Явно задаем расстояние в 700 км
		assert_equal 2100.0, cargo.calculate_price # Ожидаемая цена: 3 руб/км
	end
end
