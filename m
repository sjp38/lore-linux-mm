Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniele Bellucci <bellucda@tiscali.it>
Subject: Re: 2.5.69-mm9
Date: Mon, 26 May 2003 21:20:14 +0200
References: <20030525042759.6edacd62.akpm@digeo.com> <200305262030.23526.bellucda@tiscali.it>
In-Reply-To: <200305262030.23526.bellucda@tiscali.it>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200305262120.14744.bellucda@tiscali.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26 May 2003 20:30, Daniele Bellucci wrote:
> fixed missing sys_kexec_load entry in syscall table (i386 only).

I still have problem with kexec
when i  launch kexec script (from kexec-tools-1.8)
i get  
kernel panic VFS: Unable to mount root on hda

i use the following parameters for kexec:
rootfstype=ext3 hdc=ide-scsi init 3




-------------------------------------------------------------------------------------------------------------------------------------------------------------
PGP PKEY      http://pgp.mit.edu:11371/pks/lookup?search=belch76@libero.it&op=index
ICQ#               104896040  
Netphone/Fax  178.605.7063
-------------------------------------------------------------------------------------------------------------------------------------------------------------

Daniele Bellucci



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
