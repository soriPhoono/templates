import "./style.css";

const versionElement = document.querySelector<HTMLSpanElement>("#version");

window.api.getVersion().then((version) => {
  if (versionElement) versionElement.textContent = `v${version}`;
});
