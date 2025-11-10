import docker

client = docker.DockerClient(base_url='unix://var/run/docker.sock')

def reiniciar(nombre_contenedor):
    cont = client.containers.get(nombre_contenedor)
    cont.restart()
    print(f"🔁 Contenedor {nombre_contenedor} reiniciado.")

reiniciar("ram_simulator")