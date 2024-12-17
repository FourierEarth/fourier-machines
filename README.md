# Fourier Machines

This repository houses configurations for various employees' company computers, build servers and other service hosts.

While not strictly necessary to perform your role, this Nix flake attempts to make device setup easier and, to a large degree, maintenance free. In the event that you have software configuration which could be useful to others, but which is not already provided as a module by this flake, please contribute or let someone on Fourier's @Nix team know.

## Onboarding & Initialization

### Step 1. Install Nix

Please use the [Determinate Systems Nix Installer] to acquire the Nix store daemon and command line tools.
This can be done with a single command:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

[Determinate Systems Nix Installer]: https://github.com/DeterminateSystems/nix-installer

> [!IMPORTANT]
> Do _not_ pass the `--determinate` argument to `install`, it would use the Determinate fork of Nix which is not guaranteed compatible with `nix-darwin`.

Please remember to restart your login shell before proceeding, or the commands used later will not be found on your `PATH`.

### Step 2. Activate the default configuration

First back up your `/etc/nix/nix.conf`. If you haven't made changes to it, you can simply delete the file.

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

Now proceed to Option A or Option B.

#### Option A. Without cloning `fourier-machines`

Next, activate the `fourier-default` system configuration.

```sh
nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake 'github:FourierEarth/fourier-machines#fourier-default'
```

#### Option B. Clone `fourier-machines` locally

This option is for those who wish to contribute configurations and maintain their own.

It is recommended to keep your local copy at `~/.config/fourier-machines`.

```sh
git clone git@github.com:FourierEarth/fourier-machines.git ~/.config/fourier-machines
```

Now you have a choice: use the `fourier-default` configuration, or add your own.

To use the default:

```sh
nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake "path:$HOME/.config/fourier-machines#fourier-default"
```

To add your own host configuration, open `~/.config/fourier-machines` in your editor and poke around. Make sure to use your machine's host name where applicable.

```sh
code ~/.config/fourier-machines
```

Double-check your hostname:

```sh
scutil --get LocalHostName
```

After adding your own host configuration to `darwinConfigurations`, the following command will build and activate the system configuration.

```sh
nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake "path:$HOME/.config/fourier-machines"
```

Notice there is no `#fourier-default` in the flake URI, that is because the `nix-darwin` flake's default command will choose the attribute in `darwinConfigurations` that matches your hostname.

### Step 3. You're done, but double-check!

Depending on whether you cloned `fourier-machines` or just used the remote URI, run one of these commands.

If you chose to evaluate the remote flake (Option A):

```sh
darwin-rebuild switch --flake 'github:FourierEarth/fourier-machines'
```

Or, if you cloned the repository **and** added your host (Option B):

```sh
darwin-rebuild switch --flake ~/.config/fourier-machines
```

If you did not add your host, please specify the name of the default configuration:

```sh
darwin-rebuild switch --flake "$HOME/.config/fourier-machines#fourier-default"
```
