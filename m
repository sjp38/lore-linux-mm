Subject: Re: 2.6.0-mm2
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1072727943.1064.15.camel@debian>
References: <20031229013223.75c531ed.akpm@osdl.org>
	 <1072727943.1064.15.camel@debian>
Content-Type: text/plain; charset=UTF-8
Message-Id: <1072731446.5170.4.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: Mon, 29 Dec 2003 21:57:26 +0100
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ramon.rey@hispalinux.es
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-12-29 at 20:59, Ramon Rey Vicente wrote:
> El lun, 29-12-2003 a las 10:32, Andrew Morton escribiA3:
> 
> > +atapi-mo-support-update.patch
> > +atapi-mo-support-timeout-fix.patch
> > 
> >  ATAPI CDROM fixups.
> 
> This happen with 2.6.0-mm1 and -mm2. With 2.6.0 all is OK.
> 
> rrey@debian:~$ cdrecord cdrom-1.iso
> Cdrecord-Clone 2.01a19 (i686-pc-linux-gnu) Copyright (C) 1995-2003 JA?rg
> Schilling
> scsidev: '/udev/hdc'
> devname: '/udev/hdc'
> scsibus: -2 target: -2 lun: -2
> Warning: Open by 'devname' is unintentional and not supported.
> cdrecord.mmap: No such file or directory. Cannot open '/udev/hdc'.
> Cannot open SCSI driver.
> cdrecord.mmap: For possible targets try 'cdrecord -scanbus'. Make sure
> you are root.
> cdrecord.mmap: For possible transport specifiers try 'cdrecord
> dev=help'.
> cdrecord.mmap: Also make sure that you have loaded the sg driver and the
> driver for
> cdrecord.mmap: SCSI hardware, eg. ide-scsi if you run IDE/ATAPI drives
> over
> cdrecord.mmap: ide-scsi emulation. For more information, install the
> cdrtools-doc
> cdrecord.mmap: package and read
> /usr/share/doc/cdrecord/README.ATAPI.setup .
> 
> The /udev/hdc have 
> brw-rw-rw-    1 root     cdrw      22,   0 2003-12-29 20:52 /udev/hdc

The same happens here. cdrecord is broken under -mm, but works fine with
plain 2.6.0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
