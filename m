From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.69-mm4
Date: Tue, 13 May 2003 08:43:20 -0400
References: <20030512225504.4baca409.akpm@digeo.com> <20030513001135.2395860a.akpm@digeo.com> <87n0hr8edh.fsf@lapper.ihatent.com>
In-Reply-To: <87n0hr8edh.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200305130843.20737.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 13, 2003 04:00 am, Alexander Hoogerhuis wrote:
>         ld -m elf_i386  -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o
> arch/i386/kernel/init_task.o   init/built-in.o --start-group
>  usr/built-in.o  arch/i386/kernel/built-in.o  arch/i386/mm/built-in.o
>  arch/i386/mach-default/built-in.o  kernel/built-in.o  mm/built-in.o
>  fs/built-in.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o
>  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  sound/built-in.o
>  arch/i386/pci/built-in.o  net/built-in.o --end-group  -o .tmp_vmlinux1
>
> kernel/built-in.o(.text+0x1005): In function `schedule':
> : undefined reference to `active_load_balance'
>
> make: *** [.tmp_vmlinux1] Error 1
> alexh@lapper ~/src/linux/linux-2.5.69-mm4 $

This happens here too on a tree that was mrproper(ed).

Ed 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
