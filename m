Date: Tue, 13 May 2003 10:55:25 +0200
Subject: Re: 2.5.69-mm4
Message-ID: <20030513085525.GA7730@hh.idb.hist.no>
References: <20030512225504.4baca409.akpm@digeo.com> <87vfwf8h2n.fsf@lapper.ihatent.com> <20030513001135.2395860a.akpm@digeo.com> <87n0hr8edh.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87n0hr8edh.fsf@lapper.ihatent.com>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Hoogerhuis <alexh@ihatent.com>, James Simmons <jsimmons@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 10:00:58AM +0200, Alexander Hoogerhuis wrote:
> And this one :)
> 
>         ld -m elf_i386  -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o arch/i386/kernel/init_task.o   init/built-in.o --start-group  usr/built-in.o  arch/i386/kernel/built-in.o  arch/i386/mm/built-in.o  arch/i386/mach-default/built-in.o  kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  sound/built-in.o  arch/i386/pci/built-in.o  net/built-in.o --end-group  -o .tmp_vmlinux1
> kernel/built-in.o(.text+0x1005): In function `schedule':
> : undefined reference to `active_load_balance'

I got this one too, as well as:
drivers/built-in.o(.text+0x7d534): In function `fb_prepare_logo':
: undefined reference to `find_logo'

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
