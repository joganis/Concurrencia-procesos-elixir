defmodule NodoCliente do
  @nodo_cliente :"cliente@10.0.67.160"
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_servicio :servicio_limpieza

  def lista_reviews do
    [
      %Review{id: 1, texto: "El producto es excelente y muy útil"},
      %Review{id: 2, texto: "La calidad es baja y no lo recomiendo"},
      %Review{id: 3, texto: "Un artículo bueno en relación precio y calidad"},
      %Review{id: 4, texto: "La entrega fue rápida y el empaque perfecto"},
      %Review{id: 5, texto: "Es un producto promedio"}
    ]
  end

  def main do
    IO.puts("CLIENTE LIMPIEZA INICIADO")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      enviar_reviews()
    else
      IO.puts("No se pudo conectar al servidor")
    end
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  def enviar_reviews do
    Enum.each(lista_reviews(), fn r ->
      send({@nombre_servicio, @nodo_servidor}, {self(), {:limpiar, r}})
    end)

    send({@nombre_servicio, @nodo_servidor}, {self(), :fin})

    recibir()
  end

  defp recibir do
    receive do
      :fin ->
        IO.puts("Cliente: finalización recibida.")
        :ok

      {id, resumen} ->
        IO.puts("Cliente → Reseña #{id} limpia: #{resumen}")
        recibir()

      otro ->
        IO.puts("Cliente: mensaje desconocido #{inspect(otro)}")
        recibir()
    end
  end
end

NodoCliente.main()
