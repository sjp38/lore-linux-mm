Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 623276B0055
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 05:52:54 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so573916fgg.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2009 02:52:52 -0800 (PST)
Date: Fri, 27 Feb 2009 13:59:35 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090227105935.GD2939@x200.localdomain>
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu> <20090226223112.GA2939@x200.localdomain> <20090227090323.GC16211@elte.hu> <20090227012209.65401324.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090227012209.65401324.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 01:22:09AM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 10:03:23 +0100 Ingo Molnar <mingo@elte.hu> wrote:
> 
> > >  arch/x86/include/asm/unistd_32.h   |    2 
> > >  arch/x86/kernel/syscall_table_32.S |    2 
> > >  include/linux/Kbuild               |    1 
> > >  include/linux/cr.h                 |   56 ++++++
> > >  include/linux/ipc_namespace.h      |    3 
> > >  include/linux/syscalls.h           |    5 
> > >  init/Kconfig                       |    2 
> > >  kernel/Makefile                    |    1 
> > >  kernel/cr/Kconfig                  |   11 +
> > >  kernel/cr/Makefile                 |    8 
> > >  kernel/cr/cpt-cred.c               |  115 +++++++++++++
> > >  kernel/cr/cpt-fs.c                 |  122 +++++++++++++
> > >  kernel/cr/cpt-mm.c                 |  134 +++++++++++++++
> > >  kernel/cr/cpt-ns.c                 |  324 +++++++++++++++++++++++++++++++++++++
> > >  kernel/cr/cpt-signal.c             |  121 +++++++++++++
> > >  kernel/cr/cpt-sys.c                |  228 ++++++++++++++++++++++++++
> > >  kernel/cr/cr-ctx.c                 |  141 ++++++++++++++++
> > >  kernel/cr/cr.h                     |   61 ++++++
> > >  kernel/cr/rst-sys.c                |    9 +
> > >  kernel/sys_ni.c                    |    3 
> > >  20 files changed, 1349 insertions(+)
> > 
> > That does not look scary to me at all. Andrew?
> 
> btw, why is there no need for a kernel/cr/cpt-net.c?

Too early :-) There is no rst-*.c counterparts either :-) But I'm
working on this.

But, yes, cpt-net.c will be definitely: all sorts of sockets, virtual
netdevices, iptables, ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
