# Bash scripts using Curl, lftp, or sshpass to automate file transfers

> These all support wildcard file lists.

> lftp has limited error reporting so it is difficult to detect problems during transfers. If this is a problem, use Curl.

## ib_ or Inbound scripts collect files from remote system.

* ib_curlftps.sh: Curl FTPS. Supports Implicit or Explicit FTPS
* ib_curlsftp.sh: Curl SFTP.
* ib_lftpftps.sh: lftp FTPS. Supports Implicit or Explicit FTPS
* ib_lftpsftp.sh: lftp SFTP.
* ib_sftpsftp.sh: sshpass and sftp.
* ib_validate.sh: Uses Curl to validate connection to remote.

## ob_ or Outbound scripts transfer files to remote system.

* ob_curlftps.sh: Curl FTPS. Supports Implicit or Explicit FTPS
* ob_curlsftp.sh: Curl SFTP.
* ob_lftpftps.sh: lftp FTPS. Supports Implicit or Explicit FTPS
* ob_lftpsftp.sh: lftp SFTP.
* ob_sftpsftp.sh: sshpass and sftp.
* ob_validate.sh: Uses Curl to validate connection to remote.
