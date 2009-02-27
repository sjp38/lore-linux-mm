Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 657D96B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 04:22:26 -0500 (EST)
Date: Fri, 27 Feb 2009 01:22:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
Message-Id: <20090227012209.65401324.akpm@linux-foundation.org>
In-Reply-To: <20090227090323.GC16211@elte.hu>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
	<20090226173302.GB29439@elte.hu>
	<20090226223112.GA2939@x200.localdomain>
	<20090227090323.GC16211@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 2009 10:03:23 +0100 Ingo Molnar <mingo@elte.hu> wrote:

> >  arch/x86/include/asm/unistd_32.h   |    2 
> >  arch/x86/kernel/syscall_table_32.S |    2 
> >  include/linux/Kbuild               |    1 
> >  include/linux/cr.h                 |   56 ++++++
> >  include/linux/ipc_namespace.h      |    3 
> >  include/linux/syscalls.h           |    5 
> >  init/Kconfig                       |    2 
> >  kernel/Makefile                    |    1 
> >  kernel/cr/Kconfig                  |   11 +
> >  kernel/cr/Makefile                 |    8 
> >  kernel/cr/cpt-cred.c               |  115 +++++++++++++
> >  kernel/cr/cpt-fs.c                 |  122 +++++++++++++
> >  kernel/cr/cpt-mm.c                 |  134 +++++++++++++++
> >  kernel/cr/cpt-ns.c                 |  324 +++++++++++++++++++++++++++++++++++++
> >  kernel/cr/cpt-signal.c             |  121 +++++++++++++
> >  kernel/cr/cpt-sys.c                |  228 ++++++++++++++++++++++++++
> >  kernel/cr/cr-ctx.c                 |  141 ++++++++++++++++
> >  kernel/cr/cr.h                     |   61 ++++++
> >  kernel/cr/rst-sys.c                |    9 +
> >  kernel/sys_ni.c                    |    3 
> >  20 files changed, 1349 insertions(+)
> 
> That does not look scary to me at all. Andrew?

btw, why is there no need for a kernel/cr/cpt-net.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
