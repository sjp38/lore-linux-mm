Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA03019
	for <linux-mm@kvack.org>; Mon, 3 Mar 2003 13:21:19 -0800 (PST)
Date: Mon, 3 Mar 2003 13:17:34 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm2
Message-Id: <20030303131734.33a95472.akpm@digeo.com>
In-Reply-To: <1046726154.30192.312.camel@dell_ss3.pdx.osdl.net>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	<1046726154.30192.312.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Hemminger <shemminger@osdl.org> wrote:
>
> I am having problems getting this to build with my config
> 
>         ld -m elf_i386  -T arch/i386/vmlinux.lds.s arch/i386/kernel/head.o arch/
> i386/kernel/init_task.o   init/built-in.o --start-group  usr/built-in.o  arch/i3
> 86/kernel/built-in.o  arch/i386/mm/built-in.o  arch/i386/mach-default/built-in.o
>   kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/buil
> t-in.o  crypto/built-in.o  lib/lib.a  arch/i386/lib/lib.a  drivers/built-in.o  s
> ound/built-in.o  arch/i386/pci/built-in.o  arch/i386/oprofile/built-in.o  net/bu
> ilt-in.o --end-group .tmp_kallsyms2.o -o vmlinux
> 4d13d7e9 A __crc_page_states__per_cpu not in per-cpu section
> make: *** [vmlinux] Error 1

Yup.  Kai has posted a fix for this.  Meanwhile the simplest
fix is to disable CONFIG_MODVERSIONS.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
