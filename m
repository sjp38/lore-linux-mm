From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304150414.h3F4EjUb018031@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <200304150344.h3F3iVrs017946@sith.maoz.com> from Jeremy Hall at
 "Apr 14, 2003 11:44:30 pm"
Date: Tue, 15 Apr 2003 00:14:45 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@sith.maoz.com>
Cc: Robert Love <rml@tech9.net>, Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new year, Jeremy Hall wrote:
> In the new year, Robert Love wrote:
> > On Mon, 2003-04-14 at 17:48, Jeremy Hall wrote:
> > 
> yes sorry for the silly dialog.  I'll post a backtrace so maybe it will be 
> more clear.
> 
and btw I appreciate your help. :)

Script started on Mon Apr 14 23:44:43 2003
Rainbow:/usr/src/linux-2.5.67 # gdb vmlinux
GNU gdb 5.3
Copyright 2002 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "i686-pc-linux-gnu"...
gdb_interrupt (irq=4, dev_id=0x0, regs=0xdae4fc74)
    at arch/i386/lib/kgdb_serial.c:194
194	            continue ;
warning: shared library handler failed to enable breakpoint
(gdb) bt
#0  gdb_interrupt (irq=4, dev_id=0x0, regs=0xdae4fc74)
    at arch/i386/lib/kgdb_serial.c:194
#1  0xc010cd68 in handle_IRQ_event (irq=4, regs=0xdae4fc74, action=0xdffee640)
    at arch/i386/kernel/irq.c:214
#2  0xc010cfd1 in do_IRQ (regs=
      {ebx = -604748800, ecx = 32, edx = -604748632, esi = -604748632, edi = 10, ebp = -622527312, eax = -622534656, xds = 123, xes = 123, orig_eax = -252, eip = -1072561613, xcs = 96, eflags = 646, esp = -604748800, xss = -1049704384})
    at arch/i386/kernel/irq.c:395
#3  0xc010b60c in common_interrupt () at net/8021q/vlan.c:130
#4  0xc033b857 in snd_pcm_period_elapsed (substream=0xc16ec840)
    at sound/core/pcm_lib.c:2014
#5  0xc0340fa8 in snd_rme9652_interrupt (irq=10, dev_id=0xc1679dc8, 
    regs=0xdae4fd20) at sound/pci/rme9652/rme9652.c:1959
#6  0xc010cd68 in handle_IRQ_event (irq=10, regs=0xdae4fd20, action=0xc1700be0)
    at arch/i386/kernel/irq.c:214
#7  0xc010cfd1 in do_IRQ (regs=
      {ebx = -622534656, ecx = 1, edx = 578454, esi = -1049704384, edi = -604748800, ebp = -622527128, eax = -1049974272, xds = 123, xes = 123, orig_eax = -246, eip = -1070407894, xcs = 96, eflags = 514, esp = -622534656, xss = -1049704384}) at arch/i386/kernel/irq.c:395
#8  0xc010b60c in common_interrupt () at net/8021q/vlan.c:130
#9  0xc0332d81 in snd_pcm_stop (substream=0xc16ec9c0, state=4)
    at sound/core/pcm_native.c:712
#10 0xc0338030 in snd_pcm_update_hw_ptr_interrupt (substream=0xc16ec9c0)
    at sound/core/pcm_lib.c:179
#11 0xc033b88e in snd_pcm_period_elapsed (substream=0xc16ec9c0)
    at sound/core/pcm_lib.c:2016
#12 0xc0340fa8 in snd_rme9652_interrupt (irq=12, dev_id=0xc17171c8, 
    regs=0xdae4fe2c) at sound/pci/rme9652/rme9652.c:1959
#13 0xc010cd68 in handle_IRQ_event (irq=12, regs=0xdae4fe2c, action=0xc1700340)
    at arch/i386/kernel/irq.c:214
#14 0xc010cfd1 in do_IRQ (regs=
      {ebx = 1064997, ecx = 433565696, edx = -1069105792, esi = -1053505848, edi = -640172440, ebp = -622526864, eax = 3688, xds = 123, xes = 123, orig_eax = -244, eip = -1072398266, xcs = 96, eflags = 582, esp = -613946388, xss = -602417088}) at arch/i386/kernel/irq.c:395
#15 0xc010b60c in common_interrupt () at net/8021q/vlan.c:130
#16 0xc01481b8 in do_no_page (mm=0xdc17d840, vma=0xd6070cc0, 
    address=3204030464, write_access=1, page_table=0xd9d7be68, pmd=0xdb67ebec)
    at mm/memory.c:1332
#17 0xc014870c in handle_mm_fault (mm=0xdc17d840, vma=0xd6070cc0, 
    address=3204030464, write_access=1) at mm/memory.c:1483
#18 0xc0146e55 in get_user_pages (tsk=0xdbde8cc0, mm=0xdc17d840, 
    start=3204030464, len=102, write=1, force=0, pages=0x0, vmas=0x0)
    at mm/memory.c:718
#19 0xc01488b4 in make_pages_present (addr=3202351104, end=3204448256)
    at mm/memory.c:1580
#20 0xc0149f3c in do_mmap_pgoff (file=0x0, addr=3202351104, len=2097152, 
---Type <return> to continue, or q <return> to quit---
    prot=7, flags=34, pgoff=0) at mm/mmap.c:733
#21 0xc0111701 in old_mmap (arg=0x40c37e0c) at arch/i386/kernel/sys_i386.c:59
(gdb) up

> _J
> 
> > 	Robert Love
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
