defmodule NodoCliente do
  @nodo_cliente :"cliente@10.0.67.160"
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_proceso :servicio_iva

  def lista_productos do
    [
      %Producto{nombre: "Teclado", stock: 10, precio_sin_iva: 100, iva: 0.19},
      %Producto{nombre: "Mouse", stock: 20, precio_sin_iva: 50, iva: 0.19},
      %Producto{nombre: "Monitor", stock: 5, precio_sin_iva: 900, iva: 0.19}
    ]
  end

  def main() do
    IO.puts("CLIENTE IVA INICIADO")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      realizar_calculos()
    else
      IO.puts("Error: no se pudo conectar al servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp realizar_calculos() do
    Enum.each(lista_productos(), fn prod ->
      send({@nombre_proceso, @nodo_servidor}, {self(), {:calcular, prod}})
    end)

    send({@nombre_proceso, @nodo_servidor}, {self(), :fin})

    recibir()
  end

  defp recibir() do
    receive do
      :fin ->
        IO.puts("Cliente: fin recibido. Termina.")
        :ok

      {nombre, total} ->
        IO.puts("Cliente → #{nombre} => #{total}")
        recibir()

      otro ->
        IO.puts("Cliente: mensaje desconocido #{inspect(otro)}")
        recibir()
    end
  end
end

NodoCliente.main()
