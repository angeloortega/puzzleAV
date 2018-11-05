Shoes.app(title: "Puzzle De Anti-Virus Mutation",width: 800, height:800)do
    @tablero = nil
    @puzzle = nil
    @contador = nil
    background "#ffb366"
    border("#cc853e",
           strokewidth: 6)
    flow(left:360, top: 30) do
        puzzle = para("AVM-000", stroke:white)
      end
    stack(margin: 12) do
      flow(top: 20,left:45)do
        button "<"
        tablero = image "images/tablero.png"
        button ">" 
      end
    end
    flow(:margin_left => '2%') do
        button "Solucion Stop-Motion"
        button "Solucion PasoxPaso"
        button "Reiniciar"
        button "Editar" do
          Shoes.app(width: 1200, height: 800)do
          button "genial"
          end
        end
        button "Acerca De"
        button "Ayuda"
      end
    flow(:margin_left => '42%') do
      contador = para("Movimientos= 0", stroke:white)
      end
    basedir = 'puzzles/'
    files = Dir.glob("*.txt")
    @puzzle.replace files[0]
  end
  