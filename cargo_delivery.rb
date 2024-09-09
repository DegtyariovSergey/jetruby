require 'net/http'
require 'json'
require 'uri'
require 'cgi'

class CargoDelivery
	API_KEY = 'eEjqAxB6NUYwuVxlHW24KOCRdkJj0hj6ckAz70rxJpUcsAyKoNvbZk23cpR2nvFm'
	API_URL = 'https://api.distancematrix.ai/maps/api/distancematrix/json?origins=51.4822656,-0.1933769&destinations=51.4994794,-0.1269979&key=eEjqAxB6NUYwuVxlHW24KOCRdkJj0hj6ckAz70rxJpUcsAyKoNvbZk23cpR2nvFm'

	attr_reader :weight, :length, :width, :height, :origin, :destination, :distance, :price

	def initialize(weight, length, width, height, origin, destination)
		@weight = weight
		@length = length
		@width = width
		@height = height
		@origin = origin
		@destination = destination
		@distance = calculate_distance
		@price = calculate_price
	end

	#Объем груза в кубических метрах
	def volume 
		(@length * @width * @height)/1_000_000.0
	end

	#Получаем расстояние между городами с помощью API
	def calculate_distance
		encoded_origin = CGI.escape(origin)
		encoded_destination = CGI.escape(destination)

		uri = URI("#{API_URL}?origins=#{encoded_origin}&destinations=#{encoded_destination}&key=#{API_KEY}")
		response = Net::HTTP.get(uri)
		data = JSON.parse(response)

		#Проверка удалось ли получить расстояние
		if data.dig('rows', 0, 'elements', 0, 'distance')
			distance_in_meters = data['rows'][0]['elements'][0]['distance']['value']
			distance_in_meters/1000.0 #Переводим в км
		else
			raise 'Не удалось вычислить расстояние'
		end
	end

	#Рассчет цены доставки
	def calculate_price
		price_per_km = if volume<1
			1
		elsif volume >=1 && weight<=10
			2
		else
			3
		end

		distance*price_per_km
	end

	#Возвращаем итоговый хеш с данными

	def result
		{
			weight: weight,
			length:  length,
			width:  width,
			height:  height,
			distance:  distance,
			price:  price
		}
	end
end

#Функция для запроса данных у пользователя
def get_input(promt)
	print "#{promt}: "
	gets.chomp
end

#Запрашиваем у пользователя данные 
weight = get_input('Введите вес груза (в кг)').to_f
length = get_input('Введите длину груза (в см)').to_f
width = get_input('Введите ширину груза (в см)').to_f
height = get_input('Введите высоту груза (в см)').to_f
origin = get_input('Введите пункт отправления')
destination = get_input('Введите пункт назначения')

#создаем объект доставки и выводим результат
begin
	cargo = CargoDelivery.new(weight, length, width, height, origin, destination)
	result = cargo.result
	puts "Груз весом #{result[:weight]} кг, размером #{result[:length]}x#{result[:width]}x#{result[:height]}см}"
	puts "Расстояние между #{origin} и #{destination}: #{result[:distance]} км"
	puts "Стоимость доставки: #{result[:price]} рублей"
rescue StandartError => e 
	puts "ошибка: #{e.message}"
end