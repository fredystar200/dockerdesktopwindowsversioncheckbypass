# Docker Desktop Windows Version Check Bypass

Temporarily bypass the **Docker Desktop Windows version check** by modifying only the Windows version information stored in the registry.

This project is intended for situations where the Docker Desktop installer incorrectly reports that your version of Windows is unsupported, even though your system is otherwise capable of running it.

After Docker Desktop has been installed, you can restore your original registry values with a single command.

---

> [!WARNING]
> **This project does NOT upgrade Windows.**
>
> It only changes a few registry values that some installers use to determine your Windows version.
> 
> **Tested on Windows 10 Enterprise LTSC, 22-July-2026 with Docker Desktop 4.83.0 / 2026-07-20**
>
> Your actual Windows kernel, features, files, and operating system remain completely unchanged.

---

## Table of Contents

- [Why does this exist?](#why-does-this-exist)
- [How it works](#how-it-works)
- [Before You Begin](#before-you-begin)
- [Project Files](#project-files)
- [Usage](#usage)
- [What Gets Modified?](#what-gets-modified)
- [Safety Features](#safety-features)
- [FAQ](#faq)
- [Disclaimer](#disclaimer)

---

# Why does this exist?

Some Windows installers—including certain versions of **Docker Desktop**—determine whether your computer is supported by reading Windows version information from the registry.

On some systems (for example):

- Windows LTSC
- Enterprise editions
- Customized Windows installations
- Older Windows 10 builds
- Certain Insider builds

The installer may incorrectly refuse to install, even though the operating system is otherwise compatible.

This project temporarily changes only those registry values so the installer detects a supported Windows version.

After installation, your original values can be restored with the revert.bat file.


---

# How it works

The project contains two Batch scripts. Clone / Download the ZIP

## Step 1

Run:

```
apply_and_backup.bat
```

This script:

- Reads your current Windows version information.
- Creates a backup of the original values.
- Applies temporary compatibility values.

---

## Step 2

Install Docker Desktop normally.

---

## Step 3

Run:

```
revert.bat
```

Your original Windows version information is restored.

---

# Before You Begin

Although these scripts include their own backup system, **it is highly recommended that you also create your own backups before modifying the registry.**

---

## Create a Registry Backup

1. Press **Win + R**
2. Type

```
regedit
```

3. Press **Enter**
4. Navigate to

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
```

5. Right-click **CurrentVersion**
6. Choose **Export**
7. Save the `.reg` file somewhere safe.

---

## Create a System Restore Point

1. Open the Start Menu.
2. Search for:

```
Create a restore point
```

3. Open **System Protection**.
4. Make sure protection is enabled for your system drive.
5. Click **Create...**
6. Give the restore point a name.
7. Wait for Windows to confirm it has been created.

---

> [!IMPORTANT]
> The automatic backup created by this project only contains the **four registry values modified by the script**.
>
> A Registry backup and a System Restore Point provide additional protection in case anything unexpected happens.

---

# Project Files

```
.
├── apply_and_backup.bat
├── revert.bat
└── CurrentVersion_ORIGINAL_BACKUP.reg
```

---

## apply_and_backup.bat

This is the script you run **before installing Docker Desktop**.

It performs two jobs.

### 1. Backup your original values

On the first run, it reads these registry values:

- CurrentBuild
- CurrentBuildNumber
- DisplayVersion
- EditionID

and stores them in

```
CurrentVersion_ORIGINAL_BACKUP.reg
```

located next to the script.

These are your **real** Windows values.

---

### Backup protection

The backup is created **only once**.

If

```
CurrentVersion_ORIGINAL_BACKUP.reg
```

already exists:

- it is NOT overwritten
- your original values remain safe
- the script simply reuses the existing backup

This prevents accidentally replacing your original backup with already modified values.

---

### Backup verification

Before modifying anything, the script confirms that the backup file was successfully created.

If the backup cannot be written:

- nothing is modified
- the script exits safely

---

### Apply compatibility values

After verifying the backup, the script changes the registry to:

| Registry Value | Temporary Value |
|----------------|-----------------|
| CurrentBuild | 28000 |
| CurrentBuildNumber | 28000 |
| DisplayVersion | 22H2 |
| EditionID | Professional |

These values satisfy installers that require a supported Windows release.

---

## revert.bat

After Docker Desktop has been installed, run:

```
revert.bat
```

This script:

1. Imports

```
CurrentVersion_ORIGINAL_BACKUP.reg
```

2. Immediately reads the registry again.

Instead of simply trusting that `reg import` succeeded, it displays the restored values so you can verify them yourself.

---

# Usage

## 1. Run as Administrator

Right-click

```
apply_and_backup.bat
```

Select

```
Run as administrator
```

Administrative privileges are required to modify these registry keys.

---

## 2. Install Docker Desktop

Run the Docker Desktop installer normally.

The installer should now detect a supported Windows version.

---

## 3. Restore your original values

Once Docker Desktop is installed:

Right-click

```
revert.bat
```

Choose

```
Run as administrator
```

Your original Windows version information will be restored.

---

# What Gets Modified?

Only the following registry key is accessed:

```
HKEY_LOCAL_MACHINE
└── SOFTWARE
    └── Microsoft
        └── Windows NT
            └── CurrentVersion
```

Only these four values are modified:

- CurrentBuild
- CurrentBuildNumber
- DisplayVersion
- EditionID

Nothing else in the registry is touched.

---

# Safety Features

This project includes several safeguards.

✅ Automatically creates a backup of your original values.

✅ Never overwrites an existing backup.

✅ Refuses to apply changes if the backup cannot be created.

✅ Uses a fixed backup filename to simplify restoration.

✅ Restores your original values with one command.

✅ Verifies the restoration by querying the registry after importing the backup.

✅ Uses only built-in Windows Batch and Registry commands.

---

# FAQ

## Does this upgrade Windows?

No.

It only changes four registry values.

Your Windows installation remains exactly the same.

---

## Does this permanently spoof Windows?

No.

The changes remain until you restore the original values using:

```
revert.bat
```

---

## Is my original Windows version saved?

Yes.

The first time you run

```
apply_and_backup.bat
```

it creates:

```
CurrentVersion_ORIGINAL_BACKUP.reg
```

containing your original registry values.

---

## Can I lose my original values?

The script is specifically designed to prevent that.

Once the backup exists, it will never overwrite it.

---

## Why verify after restoring?

While `reg import` usually succeeds, the script immediately queries the registry afterward and prints the restored values.

This lets you confirm that the restoration actually happened instead of relying only on the command's exit code.

---

## Does this require PowerShell?

No.

Everything is implemented using standard Windows Batch and Registry commands that are included with Windows.

---

# Disclaimer

MIT License

Copyright (c) 2026 fredystar200

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Modifying the Windows Registry always carries some risk. Read the scripts before running them, understand what they do, and always keep backups of your system.

The authors are not responsible for any damage, data loss, or issues resulting from the use of this project.

Use this software entirely at your own risk.
