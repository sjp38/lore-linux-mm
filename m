Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E39F76B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 10:51:17 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so446188fgg.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 07:51:15 -0800 (PST)
Date: Thu, 26 Feb 2009 18:57:55 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090226155755.GA1456@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234479845.30155.220.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, mingo@elte.hu, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 12, 2009 at 03:04:05PM -0800, Dave Hansen wrote:
> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... kernel/cpt/ | diffstat 
>  Makefile        |   53 +
>  cpt_conntrack.c |  365 ++++++++++++
>  cpt_context.c   |  257 ++++++++
>  cpt_context.h   |  215 +++++++
>  cpt_dump.c      | 1250 ++++++++++++++++++++++++++++++++++++++++++
>  cpt_dump.h      |   16 
>  cpt_epoll.c     |  113 +++
>  cpt_exports.c   |   13 
>  cpt_files.c     | 1626 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  cpt_files.h     |   71 ++
>  cpt_fsmagic.h   |   16 
>  cpt_inotify.c   |  144 ++++
>  cpt_kernel.c    |  177 ++++++
>  cpt_kernel.h    |   99 +++
>  cpt_mm.c        |  923 +++++++++++++++++++++++++++++++
>  cpt_mm.h        |   35 +
>  cpt_net.c       |  614 ++++++++++++++++++++
>  cpt_net.h       |    7 
>  cpt_obj.c       |  162 +++++
>  cpt_obj.h       |   62 ++
>  cpt_proc.c      |  595 ++++++++++++++++++++
>  cpt_process.c   | 1369 ++++++++++++++++++++++++++++++++++++++++++++++
>  cpt_process.h   |   13 
>  cpt_socket.c    |  790 ++++++++++++++++++++++++++
>  cpt_socket.h    |   33 +
>  cpt_socket_in.c |  450 +++++++++++++++
>  cpt_syscalls.h  |  101 +++
>  cpt_sysvipc.c   |  403 +++++++++++++
>  cpt_tty.c       |  215 +++++++
>  cpt_ubc.c       |  132 ++++
>  cpt_ubc.h       |   23 
>  cpt_x8664.S     |   67 ++
>  rst_conntrack.c |  283 +++++++++
>  rst_context.c   |  323 ++++++++++
>  rst_epoll.c     |  169 +++++
>  rst_files.c     | 1648 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  rst_inotify.c   |  196 ++++++
>  rst_mm.c        | 1151 +++++++++++++++++++++++++++++++++++++++
>  rst_net.c       |  741 +++++++++++++++++++++++++
>  rst_proc.c      |  580 +++++++++++++++++++
>  rst_process.c   | 1640 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  rst_socket.c    |  918 +++++++++++++++++++++++++++++++
>  rst_socket_in.c |  489 ++++++++++++++++
>  rst_sysvipc.c   |  633 +++++++++++++++++++++
>  rst_tty.c       |  384 +++++++++++++
>  rst_ubc.c       |  131 ++++
>  rst_undump.c    | 1007 ++++++++++++++++++++++++++++++++++
>  47 files changed, 20702 insertions(+)
> 
> One important thing that leaves out is the interaction that this code
> has with the rest of the kernel.  That's critically important when
> considering long-term maintenance, and I'd be curious how the OpenVZ
> folks view it. 

OpenVZ as-is in some cases wants some functions to be made global
(and if C/R code will be modular, exported). Or probably several
iterators added.

But it's negligible amount of changes compared to main code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
