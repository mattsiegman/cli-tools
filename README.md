# cli-tools

Various tools I've written to help me do things.

## publish_article

Ruby script to publish articles to a jekyll site. 

### Running

Should be run from the jekyll site's directory, but can handle being in one of the subdirectories 
(such as `_drafts`) when it is run. Takes a list of relative file paths as arguments, adds/updates 
necessary front matter, writes the output into `_posts` and then deletes the original file.

### Permissions 

Requires the necessary file permissions to do all this on the original files and on the `_posts`
subdirectory

### Notes

I only tested this with `.md` post files, but in theory it should work with other extensions/formats 
too (`.markdown`, `.html`, etc.)

### Example

```
jekyll_site/$ ~/publish_article _drafts/toast-is-delicious.md _drafts/2024-09-14-this-was-posted-now-its-not.md
```
