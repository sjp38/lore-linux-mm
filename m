From: Badari Pulavarty <pbadari@us.ibm.com>
Message-Id: <200210071745.g97Hjth23332@eng2.beaverton.ibm.com>
Subject: Re: 2.5.40-mm2
Date: Mon, 7 Oct 2002 10:45:55 -0700 (PDT)
In-Reply-To: <3DA0854E.CF9080D7@digeo.com> from "Andrew Morton" at Oct 06, 2002 10:47:42 AM PST
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew,

I get following compile errors while using 2.5.40-mm2.
Missing some exports ?

- Badari

        ld -m elf_i386 -e stext -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o arch/i386/kernel/init_task.o  init/built-in.o --start-group  arch/i386/kernel/built-in.o  arch/i386/mm/built-in.o  arch/i386/mach-generic/built-in.o  kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/built-in.o  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  sound/built-in.o  arch/i386/pci/built-in.o  net/built-in.o --end-group -o .tmp_vmlinux
drivers/built-in.o: In function `aic7xxx_biosparam':
drivers/built-in.o(.text+0xcfc71): undefined reference to `__udivdi3'
drivers/built-in.o(.text+0xcfca8): undefined reference to `__udivdi3'
drivers/built-in.o: In function `qla1280_proc_info':
drivers/built-in.o(.text+0xd0ca0): undefined reference to `get_free_page'
drivers/built-in.o: In function `qla1280_biosparam':
drivers/built-in.o(.text+0xd1daa): undefined reference to `__udivdi3'
drivers/built-in.o(.text+0xd1dce): undefined reference to `__udivdi3'
make: *** [.tmp_vmlinux] Error 1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
