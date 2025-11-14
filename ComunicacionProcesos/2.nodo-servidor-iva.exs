defmodule Calculo do
  def calcular(%Producto{nombre: n, precio_sin_iva: p, iva: i}) do
    total = p * (1 + i)
    :timer.sleep(500)   # Simula trabajo en el servidor
    IO.puts("Servidor: #{n} calculado => #{Float.round(total, 2)}")
    {n, Float.round(total, 2)}
  end
end

defmodule NodoServidor do
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_proceso :servicio_iva

  def main() do
    IO.puts("SERVIDOR IVA INICIADO")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    bucle()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp bucle() do
    receive do
      {cliente, :fin} ->
        send(cliente, :fin)
        bucle()

      {cliente, {:calcular, %Producto{} = prod}} ->
        resultado = Calculo.calcular(prod)
        send(cliente, resultado)
        bucle()

      otro ->
        IO.puts("Servidor: mensaje desconocido #{inspect(otro)}")
        bucle()
    end
  end
end

NodoServidor.main()
