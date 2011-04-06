Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6A2F8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 18:50:24 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p36MYlwM009770
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 16:34:47 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p36MoJve108466
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 16:50:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p36MoHGJ009103
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 16:50:18 -0600
Date: Thu, 7 Apr 2011 04:20:13 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 23/26] 23: perf: show possible probes
 in a given executable file or library.
Message-ID: <20110406225013.GB5806@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143707.15455.66114.sendpatchset@localhost6.localdomain6>
 <4D999A2F.4020204@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4D999A2F.4020204@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>

* Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com> [2011-04-04 19:15:11]:

> (2011/04/01 23:37), Srikar Dronamraju wrote:
> > Enhances -F/--funcs option of "perf probe" to list possible probe points in
> > an executable file or library. A new option -e/--exe specifies the path of
> > the executable or library.
> 
> I think you'd better use -x for abbr. of --exe, since -e is used for --event
> for other subcommands.

Okay, 

> 
> And also, it seems this kind of patch should be placed after perf-probe
> uprobe support patch, because without uprobe support, user binary analysis
> is meaningless. (In the result, this introduces -u/--uprobe option without
> uprobe support)
> 

Okay, I can do that, Should we do the listing before or after the uprobe
can place a breakpoint is arguable.

> 
> > Show last 10 functions in /bin/zsh.
> > 
> > # perf probe -F -u -e /bin/zsh | tail
> 
> I also can't understand why -u is required even if we have -x for user
> binaries and -m for kernel modules.
> 

yes, for the listing we can certainly do without -u option.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
