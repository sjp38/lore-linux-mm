Subject: Re: 2.5.63-mm2
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030303131734.33a95472.akpm@digeo.com>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	 <1046726154.30192.312.camel@dell_ss3.pdx.osdl.net>
	 <20030303131734.33a95472.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1046729013.30197.316.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 03 Mar 2003 14:03:33 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-03-03 at 13:17, Andrew Morton wrote:
> Stephen Hemminger <shemminger@osdl.org> wrote:
> >
> > I am having problems getting this to build with my config
> > 
> >         ld -m elf_i386  -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o arch/
> > i386/kernel/init_task.o   init/built-in.o --start-group  usr/built-in.o  arch/i3
> > 86/kernel/built-in.o  arch/i386/mm/built-in.o  arch/i386/mach-default/built-in.o
> >   kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/buil
> > t-in.o  crypto/built-in.o  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  s
> > ound/built-in.o  arch/i386/pci/built-in.o  arch/i386/oprofile/built-in.o  net/bu
> > ilt-in.o --end-group .tmp_kallsyms2.o -o vmlinux
> > 4d13d7e9 A __crc_page_states__per_cpu not in per-cpu section
> > make: *** [vmlinux] Error 1
> 
> Yup.  Kai has posted a fix for this.  Meanwhile the simplest
> fix is to disable CONFIG_MODVERSIONS.

Thanks, turning off CONFIG_MODVERSIONS builds. Next problem is that
it hangs when loading the usb module during boot up.
This appears to be as i/o scheduler specific, because same kernel boots
with "elevator=deadline".

Smells like another AS scheduler bug.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
