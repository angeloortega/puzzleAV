#
						#      .__                     
						#___  _|__|______ __ __  ______
						#\  \/ /  \_  __ \  |  \/  ___/
						# \   /|  ||  | \/  |  /\___ \ 
						#  \_/ |__||__|  |____//____  >
						#                           \/
#______________________Estudiante: Angelo Ramírez Ortega____________________
#______________________Grupo: Lenguajes de Programación____________________
#______________________Carnet: 2017080055__________________________________

class GameFiles
    def loadPuzzle(files, index)
		fh = open files[index]
		 		 
		content = fh.read
		 
		fh.close
		contador = 0
		board =[]
		subboard = []
		primero = true

		content.split('').each { |c|
		if c === "\n"
			next
		end
		if contador == 24
			then
			board << subboard
	    elsif ((contador % 5) == 0) && (contador != 0)
	    	then
	    	if primero
	    		then
	    		subboard << "."
	    		primero = false
	    	end
	    	board << subboard
	    	subboard = []
	    end
	    subboard << c
	    contador = contador + 1

		}
	 	return board
	end

	def loadSolution(files,index)
		fh = open ("./puzzles/SOL-"+ files[index].chars.last(7).join)
		 		 
		content = fh.read
		 
		fh.close
		return content
	end
	def fileExists(files, index)
		return File.file?("./puzzles/SOL-"+ files[index].chars.last(7).join)
	end
	def saveString(files, index, newTxt)
		File.delete("./puzzles/AVM-"+ files[index].chars.last(7).join) if File.exist?("./puzzles/AVM-"+ files[index].chars.last(7).join)
		File.delete("./puzzles/SOL-"+ files[index].chars.last(7).join) if File.exist?("./puzzles/SOL-"+ files[index].chars.last(7).join)
		File.write("./puzzles/AVM-"+ files[index].chars.last(7).join, newTxt)
	end
end

class Tablero
	def initialize(shoes)
    	@index = 0
    	@contador = 0
    	@files =Dir["./puzzles/AVM*.txt"]
  	    @files = @files.sort
  	    @shoes = shoes
  	    @img = nil
  	    @seleccion = nil
  	    @board = nil
  	    @previousMove = nil
  	    @bitacora = ""
  	    @orientacion = ""
  	    @fileHandler = GameFiles.new
  	    @solucionando = false
  	    @indexSolucion = 0
  	    @stringSol = ""
  	end
  	def getIndex()
  		return @index
  	end
  	def solucionExiste()
  		return @fileHandler.fileExists(@files,@index)
  	end

  	def solucionAutomatica()
  		@solucionando = true
			reset
  			movimientos = @fileHandler.loadSolution(@files, @index)
			movimientos.split(' ').each { |mov|
				mov.split('').each { |c|
				if ["A", "B", "C", "D", "E", "F"].include? c
					then
					@seleccion = c
				else
					@orientacion = c
					@contador = @contador + 1
					makeMoveSol
					sleep(1)
				end
				}
			}
  		@solucionando = false

  	end
  	def solucionPaso()
  		if @solucionando #siguiente movimiento
  			then
  			if @stringSol.to_s.strip.empty?
  				@solucionando = false
  			else
  				contador = 0
  				while ["A", "B", "C", "D", "E", "F"," "].include? @stringSol[contador]
  					if ["A", "B", "C", "D", "E", "F"].include? @stringSol[contador]
  						then
  						@seleccion = @stringSol[contador]
  					end
  					contador += 1
  				end
  				@orientacion = @stringSol[contador]
  				contador += 1
				@contador = @contador + 1
  				makeMoveSol
  				@stringSol = @stringSol[contador..-1]
  			end

  		else
  			if @fileHandler.fileExists(@files,@index)
	  			then
				reset
	  			@stringSol = @fileHandler.loadSolution(@files, @index)
				@solucionando = true
				solucionPaso()
	  		else
	  			@shoes.alert("No existe solucion para el puzzle actual. Juegalo y completalo para generarla.")
	  		end
	  	end
  	end
  	def getAllInstances()
  		instances = []
  		@board.each_with_index do |x, xi|
			x.each_with_index do |y, yi|
				if @board[xi][yi] == @seleccion
					then
					subinstance = [xi,yi]
					instances << subinstance
				end
			end
		end
		return instances
	end

	def puzzleSolucionado 
		@shoes.alert("Buen trabajo! Has solucionado el puzzle y la respuesta quedó guardada.")
		File.delete("./puzzles/SOL-"+ @files[@index].chars.last(7).join) if File.exist?("./puzzles/SOL-"+ @files[@index].chars.last(7).join)
		File.write("./puzzles/SOL-"+ @files[@index].chars.last(7).join, @bitacora)
		reset
	end

  	def validMove(x,y) #se determina si es posible mover la pieza hacia la direccion especificada
  		instances = getAllInstances
  		instances.each do |pos|
  			if (pos[0] + x >= 0) && (pos[0] + x < 5) && (pos[1] + y >= 0) && (pos[1] + y < 5)
  				then
  				if (@board[pos[0] + x][pos[1] + y] != @seleccion) && (@board[pos[0] + x][pos[1] + y] != ".")
  					then
  					return false
  				end
  			elsif (pos[0] + x == 0) && (pos[1] + y > 5) && (@seleccion == "A")
  				then
  				recordMovement
  				puzzleSolucionado
  			elsif (pos[1] + y >= 0) && (pos[1] + y <= 5) && (pos[0] + x == 0)
  				then
  				if (@board[pos[0] + x][pos[1] + y] != @seleccion) && (@board[pos[0] + x][pos[1] + y] != ".")
  					then
  					return false
  				end
  			else
  				return false
  			end

  		end
  		return true
  	end

  	def recordMovement()
  		if @bitacora.to_s.strip.empty?
  			then
  			@bitacora = @seleccion
  		elsif @previousMove != @seleccion
  			then
  			@bitacora = @bitacora + " " + @seleccion
  		end
  		@bitacora = @bitacora + @orientacion
  	end
  	
  	def makeMove(x,y) #una vez confirmado se realiza el movimiento
  		instances = getAllInstances
  		instances.each do |pos|
  			@board[pos[0]][pos[1]] = "."
  		end
  		instances.each do |pos|
  			@board[pos[0] + x][pos[1] + y] = @seleccion
  		end
  		@contador = @contador + 1
  		recordMovement
  		@previousMove = @seleccion
  		drawPuzzle
  	end
  	def makeMoveSol() #Movimiento de solucion
  		x= 0
  		y= 0
  		if "L" == @orientacion
  			then
  			y=-1
  		elsif "R" == @orientacion
  			y=1
  		elsif "N" == @orientacion
  			x=-1
  		else
  			x=1
  		end
  		instances = getAllInstances
  		instances.each do |pos|
  			@board[pos[0]][pos[1]] = "."
  		end
  		instances.each do |pos|
  			@board[pos[0] + x][pos[1] + y] = @seleccion
  		end
  		@previousMove = @seleccion
  		drawPuzzle
  	end
 	def mover(direccion)
 		if @solucionando
 			then
 			return
 		else
	  		if(["A", "B", "C", "D", "E", "F"].include? @seleccion)
	  			then
	  			case direccion.to_s
	  			when "left"
	  				@orientacion = "L"
	  				if(validMove(0,-1))
	  					then
	  					makeMove(0,-1)
	  				end
	  			when "right"
	  				@orientacion = "R"
	  				if(validMove(0,1))
	  					then
	  					makeMove(0,1)
	  				end
	  			when "down"
	  				@orientacion = "S"
	  				if(validMove(1,0))
	  					then
	  					makeMove(1,0)
	  				end
	  			when "up"
	  				@orientacion = "N"
	  				if(validMove(-1,0))
	  					then
	  					makeMove(-1,0)
	  				end
	  			end
	  		end
	  	end
  	end

	def puzzleSiguiente()
		if @index + 1 < @files.length
		then
			@index = @index + 1
		else
			@index = 0
		end
		reset
	end

	def puzzleAnterior()
		if @index - 1 >= 0
		then
			@index = @index - 1
		else
		@index = @files.length - 1
		end
		reset
	end

	def getCoordenada(coord)
		coord = (((coord-80)/100)-1)
		if coord < 0
			then
			coord = 0
		end
		if coord > 4
			then
			coord = 4
		end
		return coord
	end
	def reset()
		@contador = 0
		@bitacora = ""
		@board = @fileHandler.loadPuzzle(@files, @index)
		drawPuzzle
	end
	def drawPuzzle()
		@shoes.background "#ffb366"
    	@shoes.border("#cc853e",strokewidth: 6)
    	@img  = @shoes.image("images/tablero.png",top: 93,left:93)
        @img.click { |button, x, y|
        	@seleccion = @board[getCoordenada(y)][getCoordenada(x)]
        } 
		@board.each_with_index do |x, xi|
			x.each_with_index do |y, yi|
			case y
			when "."
				next
			when "A"
				@shoes.fill @shoes.red
			when "B"
				@shoes.fill @shoes.yellow
			when "C"
				@shoes.fill @shoes.green
			when "D"
				@shoes.fill @shoes.darkblue
			when "E"
				@shoes.fill @shoes.purple
			when "F"
				@shoes.fill @shoes.orange
			when "H"
				@shoes.fill @shoes.gray
			end
				@shoes.oval(left: 155 + (100*yi),top: 150 + (100 *xi),radius: 40)
			  end
		end
	@shoes.para(@files[@index].split('/')[2], stroke:@shoes.white,left:360, top: 30)
	@shoes.para("Movimientos= " + @contador.to_s, stroke:@shoes.white,left:320, top: 740) 
	end
end

class Validator
	def validateCoordinates(coordinates) #Verifica que las coordenadas agregadas sean correectas
		coordinates.each do |pos|
			if pos.length != 2
				then
				return false
			end
  			if pos[1] > 4 && pos[0] != 0
  			then
  			return false
  			elsif pos[1] > 5 && pos[0] == 0
  			then
  			return false
  			elsif pos[0] > 4 || pos[0] < 0 || pos[1] > 4 || pos[1] < 0
  				then
  				return false
  			end
  		end
  		return true
	end

	def validatePiece(coordinates, piece) #Verifica que las coordenadas para una pieza particular sean correctas
		case piece
			when "A"
				if coordinates.length != 2
					then
					return false
					end
				if coordinates[0][0] != coordinates [1][0]
					then
					return false
				end
				if (coordinates[1][1] - coordinates[0][1]) != 1
					return false
				end
				return true
			when "B"
				if coordinates.length != 2
					then
					return false
					end
				if (coordinates[0][0] - coordinates[1][0]).abs != 1
					then
					return false
				end
				if (coordinates[0][1] - coordinates[1][1]).abs != 1
					return false
				end
				return true
			when "C"
				if coordinates.length != 3
					then
					return false
					end
				if coordinates[0][0] == coordinates [1][0] && (coordinates[1][1] - coordinates[0][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[2][1] - coordinates[1][1]) == 1
					then
					return true
				end
				
				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[1][1] - coordinates[0][1]) == 1 && coordinates[2][0] == coordinates[1][0] && (coordinates[2][1] - coordinates[1][1]) == 1
					then
					return true
				end

				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[0][1] - coordinates[1][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && coordinates[2][1] == coordinates[1][1]
					then
					return true
				end
				if (coordinates[1][0] - coordinates [0][0]) == 1 && coordinates[0][1] == coordinates[1][1] && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[1][1] - coordinates[2][1]) == 1
					then
					return true
				end
				return false
			when "D" 
				if coordinates.length != 3
					then
					return false
					end
				if coordinates[0][0] == coordinates [1][0] && (coordinates[1][1] - coordinates[0][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && coordinates[2][1] == coordinates[1][1]
					then
					return true
				end
				
				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[0][1] - coordinates[1][1]) == 1 && coordinates[2][0] == coordinates[1][0] && (coordinates[2][1] - coordinates[1][1]) == 1
					then
					return true
				end

				if (coordinates[1][0] - coordinates [0][0]) == 1 && coordinates[0][1] == coordinates[1][1] && coordinates[2][0] == coordinates[1][0] && (coordinates[2][1] - coordinates[1][1]) == 1
					then
					return true
				end
				if coordinates[1][0] == coordinates [0][0] && (coordinates[1][1] - coordinates[0][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[1][1] - coordinates[2][1]) == 1
					then
					return true
				end
				return false

			when "E" || "F"
				if coordinates.length != 3
					then
					return false
					end
				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[0][1] - coordinates[1][1]) == 1 && coordinates[2][0] == coordinates[1][0] && (coordinates[2][1] - coordinates[1][1]) == 2
					then
					return true
				end
				
				if coordinates[1][0] == coordinates [0][0] && (coordinates[1][1] - coordinates[0][1]) == 2 && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[1][1] - coordinates[2][1]) == 1
					then
					return true
				end

				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[0][1] - coordinates[1][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[2][1] - coordinates[1][1]) == 1
					then
					return true
				end
				if (coordinates[1][0] - coordinates [0][0]) == 1 && (coordinates[1][1] - coordinates[0][1]) == 1 && (coordinates[2][0] - coordinates[1][0]) == 1 && (coordinates[1][1] - coordinates[2][1]) == 1
					then
					return true
				end
				return false

			when "H"
				if coordinates.length != 1
					then
					return false
					end
			end
	end

end

class StringParser

	def getCoordinates(stringCoords) #Parsea los strings a coordenadas
		coordinates = []
		auxCoord = []
		i = 0
		j = 0
		size = stringCoords.length
		while i < size
			c = stringCoords[i]
			if c == ")"
				then
				coordinates << auxCoord
				auxCoord = []
			elsif c == "("
				if i + 3 < size
				then
					auxCoord << stringCoords[i+1].to_i
					auxCoord << stringCoords[i+3].to_i
					i += 3
				end
			end
			i += 1
		end
		return coordinates
	end
end

class Editor #Editor de puzzles
	def initialize(shoes, index)
    	@index = index
    	@contador = 0
  	    @shoes = shoes
  	    @img = nil
  	    @seleccion = nil
  	    @orientacion = ""
  	    @fileHandler = GameFiles.new
  	    @strParser = StringParser.new
  	    @val = Validator.new 
   	   	@board = @fileHandler.loadPuzzle(Dir["./puzzles/AVM*.txt"], @index)
  	end
  	def getAllInstances()
  		instances = []
  		@board.each_with_index do |x, xi|
			x.each_with_index do |y, yi|
				if @board[xi][yi] == @seleccion
					then
					subinstance = [xi,yi]
					instances << subinstance
				end
			end
		end
		return instances
	end

	def getCoordenada(coord)
		coord = (((coord-80)/100)-1)
		if coord < 0
			then
			coord = 0
		end
		if coord > 4
			then
			coord = 4
		end
		return coord
	end
	def reset()
		@board = @fileHandler.loadPuzzle(Dir["./puzzles/AVM*.txt"], @index)
		drawPuzzle
	end
	def poner(pieza,coordenadas)
		@seleccion = pieza
		coordenadas.each do |pos|
			@board[pos[0]][pos[1]] = pieza
		end
		drawPuzzle
	end
	def Agregar(pieza, coordenadas)
		@seleccion = pieza
		if @seleccion.to_s.strip.empty? || !(["A","B","C","D","E","F","H"].include? @seleccion) || coordenadas.to_s.strip.empty?
			then
			@shoes.alert("Datos incorrectos")
		end
		coordinates = @strParser.getCoordinates(coordenadas)
			if !(@val.validateCoordinates(coordinates))
				then
				@shoes.alert("Coordenadas incorrectas")
				return false
			elsif !(@val.validatePiece(coordinates,pieza))
				then
				@shoes.alert("Coordenadas incorrectas para la pieza " + pieza)
				return false
			end
			Eliminar(pieza)
			poner(pieza,coordinates)
			return true
	end
	def Eliminar(pieza)
		@seleccion = pieza
		if @seleccion.to_s.strip.empty? || !(["B","C","D","E","F","H"].include? @seleccion)
			then
			return
		end
		instances = getAllInstances
		instances.each do |pos|
			@board[pos[0]][pos[1]] = "."
		end
		drawPuzzle
	end
	def Guardar()
		strGuard = ""
		contador = 4
		@board.each_with_index do |x, xi|
			x.each_with_index do |y, yi|
			if(yi > 4)
				then
				contador = contador
			else
				strGuard = strGuard + y
				if contador == 0
					then
					strGuard = strGuard + "\n"
					contador = 4
				else
					contador -= 1
				end
			end
			end
		end
		@shoes.alDert("El puzzle se ha guardado.")
		@fileHandler.saveString(Dir["./puzzles/AVM*.txt"], @index,strGuard)
	end

	def drawPuzzle()
		@shoes.background "#ffb366"
    	@shoes.border("#cc853e",strokewidth: 6)
    	@img  = @shoes.image("images/tablero.png",top: 100,left:100)
		@board.each_with_index do |x, xi|
			x.each_with_index do |y, yi|
			case y
			when "."
				next
			when "A"
				@shoes.fill @shoes.red
			when "B"
				@shoes.fill @shoes.yellow
			when "C"
				@shoes.fill @shoes.green
			when "D"
				@shoes.fill @shoes.darkblue
			when "E"
				@shoes.fill @shoes.purple
			when "F"
				@shoes.fill @shoes.orange
			when "H"
				@shoes.fill @shoes.gray
			end
				@shoes.oval(left: 162 + (100*yi),top: 157 + (100 *xi),radius: 40)
			  end
		end
	end
end

Shoes.app(title: "Puzzle De Anti-Virus Mutation",width: 800, height:800)do
    tablero = nil
    puzzle = nil
    cantidadMovimientos = nil
    board = Tablero.new(self)
    background "#ffb366"
    keypress do |k|
     board.mover k
   	end
    border("#cc853e",
           strokewidth: 6)

    flow(left:360, top: 30) do
        puzzle = para("AVM-000", stroke:white)
      end
    stack(margin: 12) do
      flow(top: 20,left:45)do
        button "<" do
        	board.puzzleAnterior
        end
        tablero = image "images/tablero.png"
        button ">" do
        	board.puzzleSiguiente
        end
      end
    end
    flow(:margin_left => '2%') do
        button "Solucion Stop-Motion"do
	        if board.solucionExiste
	    	then
	    	  	Thread.new {
	        	board.solucionAutomatica
	        	}
	    	else
	    		alert("No existe solucion para el puzzle actual. Juegalo y completalo para generarla.")

	   	 	end
   	 	end

        button "Solucion PasoxPaso"do
			board.solucionPaso
    	end
        button "Reiniciar" do
        	board.reset
        end
        button "Editar" do
          Shoes.app(title:"Editor de Puzzles",width: 800, height: 800)do
		            background "#ffb366"
		    		border("#cc853e",
		           	strokewidth: 6)
		          editor = Editor.new(self,board.getIndex)
		        flow(left:360, top: 30) do
		        	editPuzzle = para("AVM-000", stroke:white)
		      	end
		    stack(left:25) do
			      flow do
			        @pieceTXT =  edit_line(width: 45,height:25)
			        @posTXT = edit_line(width: 200,height:25)
			        button "Agregar"do
			        	editor.Agregar(@pieceTXT.text,@posTXT.text)
			    	end
			        button "Eliminar"do
			        	editor.Eliminar(@pieceTXT.text)
			    	end
			    	button "Guardar"do
			        	editor.Guardar()
			    	end
			      end
		    end
		    editor.drawPuzzle
        end
    end
        button "Acerca De" do
        	Shoes.app(title:"Editor de Puzzles",width: 800, height: 200)do
        	para "Puzzle de Anti-Virus Mutation, hecho por: \nAngelo Ramirez Ortega - angramirez@ic-itcr.ac.cr \nTecnologico de Costa Rica - Lenguajes de Programacion Grupo 1\n2017080055"
        	end
        end
        button "Ayuda" do
        	Shoes.app(title:"Editor de Puzzles",width: 800, height: 200)do
       		para "Ayuda:\n\nAl hacer click en una ficha, esta queda seleccionada,\nse hacen movimientos utilizando las flechas de arriba, abajo, izquierda derecha.\nPara cancelar la seleccion solo hace falta hacer click a otra ficha.\nPara cambiar de puzzle se utilizan las flechas encima del tablero.\nPara iniciar la solucion automatica se hace click solucion automatica.\nPara iniciar la solucion manual se hace click en solucion paso x paso y de nuevo para el proximo paso.\nPara salir de la aplicacion se presiona la x en el boton superior derecho.\nPara desplegar el acerca de se hace click sobre el boton acerca de\nPara agregar un puzzle se agrega el puzzle con el formato correcto visto en clases y se agrega al folder en el que se encuentra el ejecutable.\nPara editar un puzzle se hace click sobre editar."
        	end
    	end
      end
    flow(:margin_left => '42%') do
      cantidadMovimientos = para("Movimientos= 0", stroke:white)
      end
      board.reset
  end
 