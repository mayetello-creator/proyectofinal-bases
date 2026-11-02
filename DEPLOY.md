# Publicar el proyecto

Esta configuración está preparada para Render. Necesitas una cuenta de Render y una copia de esta carpeta en un repositorio GitHub.

1. Sube el contenido completo de esta carpeta a un repositorio GitHub.
2. En Render, crea un **Blueprint** y conecta ese repositorio. Render leerá `render.yaml`, creará el servicio PHP y PostgreSQL e importará `proyecto.sql` al iniciar por primera vez.
3. Cuando termine el despliegue, abre el servicio `eps-villavicencio` en Render y usa su URL `onrender.com`. La clave de acceso generada aparece en **Environment** como `APP_ACCESS_PASSWORD`; compártela solo con quienes deban entrar.

La base incluye afiliados e historiales de ejemplo. La aplicación pide clave antes de mostrar o modificar datos. No cargues información médica real en esta instancia pública.

El plan gratuito sirve para demostración: Render puede dormir el sitio tras 15 minutos sin visitas y su PostgreSQL gratuito vence a los 30 días. Para conservar datos y uso continuo, elige un plan de base de datos que no expire antes de crear el Blueprint.
