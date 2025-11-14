defmodule Validacion do

  def validar(%User{email: email, edad: edad, nombre: nombre}) do
    :timer.sleep(Enum.random(3..10))

    errores = []
    errores = if String.contains?(email, "@"), do: errores, else: ["Email inválido" | errores]
    errores = if edad >= 0, do: errores, else: ["Edad inválida" | errores]
    errores = if String.trim(nombre) != "", do: errores, else: ["Nombre vacío" | errores]

    resultado =
      if errores == [] do
        IO.puts("Validado: #{email}")
        {email, :ok}
      else
        IO.puts("Invalido: #{email}: #{Enum.join(errores, ", ")}")
        {email, {:error, Enum.reverse(errores)}}
      end


    resultado
  end


  def secuencial(usuarios) do
    Enum.map(usuarios, &validar/1)
  end


  def concurrente(usuarios) do
    usuarios
    |> Enum.map(fn u -> Task.async(fn -> validar(u) end) end)
    |> Task.await_many()
  end


   def generar_usuarios(n \\ 20) do
    nombres = ["Ana", "Luis", "Pedro", "Maria", "Juan", ""]   # algunos vacíos
    partes = ["persona", "user", "test", "demo", "mail"]
    dominios_validos = ["gmail.com", "hotmail.com", "empresa.com"]
    dominios_invalidos = ["sin-dominio", "xxxx", "prueba"]     # NO tienen @

    Enum.map(1..n, fn _ ->
      if :rand.uniform() < 0.7 do
        # 70% válidos
        %User{
          email: "#{Enum.random(partes)}#{Enum.random(1..999)}@#{Enum.random(dominios_validos)}",
          edad: Enum.random([0, 5, 25, 40, 80]),
          nombre: Enum.random(nombres)
        }
      else
        # 30% inválidos
        %User{
          email: "#{Enum.random(partes)}#{Enum.random(1..999)}.#{Enum.random(dominios_invalidos)}",
          edad: Enum.random([-5, -1, 200]),
          nombre: ""                             
        }
      end
    end)
  end


  def iniciar do
    usuarios = generar_usuarios()

    IO.puts("\n VALIDACIÓN SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Validacion, :secuencial, [usuarios]})

    IO.puts("\n VALIDACIÓN CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Validacion, :concurrente, [usuarios]})


    IO.puts("\n RESULTADOS FINALES")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nSimulación completada.\n")
  end
end

Validacion.iniciar()
