## redhat 6.9安装libreoffice

**LibreOffice 5.4.7.2是一个较旧的版本，但它是5.x系列的最终版本之一，因此包括了该系列的所有修复和改进。可以预期这个版本与Red Hat Enterprise Linux 6.9更好地兼容，因为它在较老的系统库上进行了测试和优化。**

**在安装之前，请确保卸载任何之前安装的LibreOffice版本，以避免版本冲突。您可以用以下命令来卸载当前版本：**

```bash
rpm -e `rpm -qa | grep libreoffice`
rpm -e `rpm -qa | grep libreoffice` --nodeps
```

随后，您可以按照以下步骤进行安装：

1.从 [LibreOffice官方](https://downloadarchive.documentfoundation.org/libreoffice/old/5.4.7.2/)  下载归档下载适用于Linux (rpm)的LibreOffice 5.4.7.2版本。

2.将下载的压缩包传输到您的RHEL 6.9系统。

3.解压下载的文件。通常，它们会被压缩为一个tar.gz文件。您可以使用下面的命令来解压：

```bash
 tar -xvf LibreOffice_5.4.7.2_Linux_x86-64_rpm.tar.gz
```

4.解压缩后，进入到 RPMs目录，然后使用 rpm命令安装所有rpm包：

```bash
cd LibreOffice_5.4.7.2_Linux_x86-64_rpm/RPMS/
sudo rpm -Uvh *.rpm
```

5.将其添加到环境变量中

```bash
echo 'export PATH="$PATH:/opt/libreoffice5.4/program"' >> ~/.bashrc
source ~/.bashrc

soffice --version
```

