Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0904F8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:28:58 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110127100157.GS19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
	 <1295957744.28776.722.camel@laptop>
	 <20110126075558.GB19725@linux.vnet.ibm.com>
	 <1296036708.28776.1138.camel@laptop>
	 <20110126153036.GN19725@linux.vnet.ibm.com>
	 <1296056756.28776.1247.camel@laptop>
	 <20110126165645.GP19725@linux.vnet.ibm.com>
	 <1296061949.28776.1343.camel@laptop>
	 <20110127100157.GS19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 27 Jan 2011 11:29:36 +0100
Message-ID: <1296124176.15234.67.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-27 at 15:31 +0530, Srikar Dronamraju wrote:
>=20
> > You can, if only to wreck your thing, you can call mmap() as often as
> > you like (until your virtual memory space runs out) and get many many
> > mapping of the same file.
> >=20
> > It doesn't need to make sense to the linker, all it needs to do is
> > confuse your code ;-)
>=20
> Currently if there are multiple mappings of the same executable
> code, only one mapped area would have the breakpoint inserted.

Right, so you could use it to make debugging harder..

> If the code were to execute from some other mapping, then it would
> work as if there are no probes.  However if the code from the
> mapping that had the breakpoint executes then we would see the
> probes.
>=20
> If we want to insert breakpoints in each of the maps then we
> would have to extend mm->uprobes_vaddr.
>=20
> Do you have any other ideas to tackle this?

Supposing I can get my preemptible mmu patches anywhere.. you could
simply call install_uprobe() while holding the i_mmap_mutex ;-)

> Infact do you think we should be handling this case?

I'm really not sure how often this would happen, but dealing with it
sure makes me feel better..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
