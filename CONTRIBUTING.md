# Contributing
Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.

## Getting Started

Setting up `Fake-Stream` for local development.

1. Fork the [Fake-Stream](https://github.com/Nibba2018/Fake-Stream) repo on GitHub.

2. Clone your fork locally:

```bash
$ git clone https://github.com/your_username_here/Fake-Stream
```

3. Add a tracking branch which can always have the latest version of Fake-Stream.

```bash
$ git remote add fake-stream https://github.com/Nibba2018/Fake-Stream
$ git fetch fake-stream
$ git branch fake-stream-master --track fake-stream/master
$ git checkout fake-stream-master
$ git pull
```

4. Create a branch from the last dev version of your tracking branch for local development:

```bash
$ git checkout -b name-of-your-bugfix-or-feature
```

5. Install it locally:
   * Check Setting up section in [README.md](README.md)

6. Now make your changes locally:

```bash
$ git add .
$ git commit -m "Your detailed description of your changes."
$ git push -u origin name-of-your-bugfix-or-feature
```

7. Submit a Pull Request on Github to the `master` branch.
