Subject: Re: 2.5.69-mm4
References: <20030512225504.4baca409.akpm@digeo.com>
	<87vfwf8h2n.fsf@lapper.ihatent.com>
	<20030513001135.2395860a.akpm@digeo.com>
	<87n0hr8edh.fsf@lapper.ihatent.com>
	<20030513085525.GA7730@hh.idb.hist.no>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 13 May 2003 13:04:18 +0200
In-Reply-To: <20030513085525.GA7730@hh.idb.hist.no>
Message-ID: <87addr85vx.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Simmons <jsimmons@infradead.org>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Helge Hafting <helgehaf@aitel.hist.no> writes:

> On Tue, May 13, 2003 at 10:00:58AM +0200, Alexander Hoogerhuis wrote:
> > And this one :)
> > 
> >         ld -m elf_i386  -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o arch/i386/kernel/init_task.o   init/built-in.o --start-group  usr/built-in.o  arch/i386/kernel/built-in.o  arch/i386/mm/built-in.o  arch/i386/mach-default/built-in.o  kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  sound/built-in.o  arch/i386/pci/built-in.o  net/built-in.o --end-group  -o .tmp_vmlinux1
> > kernel/built-in.o(.text+0x1005): In function `schedule':
> > : undefined reference to `active_load_balance'
> 
> I got this one too, as well as:
> drivers/built-in.o(.text+0x7d534): In function `fb_prepare_logo':
> : undefined reference to `find_logo'
> 

make clean; make on mine, still there...

mvh,
A
- -- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Processed by Mailcrypt 3.5.8 <http://mailcrypt.sourceforge.net/>

iD8DBQE+wNEvCQ1pa+gRoggRAgi4AJ9gabgNlPOBxzTQmom8acDyaYA38QCgpg+w
fcZ3iMKojuGnvp0iTKGMDyE=
=0Gov
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
