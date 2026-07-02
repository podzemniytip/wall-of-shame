const ghpages = require("gh-pages");

ghpages.publish(".", {
  branch: "gh-pages",
  src: ["index.html", "README.md", "WallOfShame.sol", ".nojekyll"],
  dotfiles: true,
  message: "deploy: Wall of Shame site",
}, (err) => {
  if (err) {
    console.error("Deploy failed:", err);
  } else {
    console.log("Deployed to gh-pages branch!");
  }
});
