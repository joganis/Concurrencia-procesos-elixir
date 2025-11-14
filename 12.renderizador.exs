defmodule Renderizador do

  def render(%Tpl{id: id, nombre: nombre, vars: vars}) do

    :timer.sleep(String.length(nombre) + length(vars) * 5)

    html =
      Enum.reduce(vars, nombre, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)

    IO.puts("Plantilla #{id} renderizada → #{html}")

    {id, html}
  end

  def secuencial(plantillas) do
    Enum.map(plantillas, &render/1)
  end

  def concurrente(plantillas) do
    plantillas
    |> Enum.map(fn t -> Task.async(fn -> render(t) end) end)
    |> Task.await_many()
  end

  def generar_plantillas(n \\ 10) do
    plantillas_base = [
      "Hola %{usuario}, tu pedido %{pedido} está listo.",
      "<p>Estimado %{usuario}, total: %{total}$</p>",
      "Bienvenido %{usuario}!",
      "Transacción %{trans} completada.",
      "<div>Hola %{usuario}, tu saldo es %{saldo}</div>"
    ]

    Enum.map(1..n, fn id ->
      base = Enum.random(plantillas_base)

      vars =
        for var <- ["usuario", "pedido", "total", "trans", "saldo"],
            String.contains?(base, "%{#{var}}") do
          {var, Enum.random(["Ana", "Juan", 100, 200, "XYZ123"])}
        end

      %Tpl{id: id, nombre: base, vars: vars}
    end)
  end

  def iniciar do
    plantillas = generar_plantillas()

    IO.puts("\nRENDER SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Renderizador, :secuencial, [plantillas]})

    IO.puts("\nRENDER CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Renderizador, :concurrente, [plantillas]})

    IO.puts("\nRESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nRender completado.\n")
  end
end

Renderizador.iniciar()
