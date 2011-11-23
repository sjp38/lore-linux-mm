Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A28766B00CD
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 15:52:39 -0500 (EST)
Message-ID: <1322081530.14799.97.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 5/30] uprobes: copy of the original
 instruction.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 21:52:10 +0100
In-Reply-To: <1322077748.20742.68.camel@frodo>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110733.10512.11835.sendpatchset@srdronam.in.ibm.com>
	 <1322073616.14799.96.camel@twins> <1322077748.20742.68.camel@frodo>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Wed, 2011-11-23 at 14:49 -0500, Steven Rostedt wrote:
> On Wed, 2011-11-23 at 19:40 +0100, Peter Zijlstra wrote:
> > On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > > +               /* TODO : Analysis and verification of instruction */
> >=20
> > As in refuse to set a breakpoint on an instruction we can't deal with?
> >=20
> > Do we care? The worst case we'll crash the program, but if we're allowe=
d
> > setting uprobes we already have enough privileges to do that anyway,
> > right?
>=20
> Well, I wouldn't be happy if I was running a server, and needed to
> analyze something it was doing, and because I screwed up the location of
> my probe, I crash the server, made lots of people unhappy and lose my
> job over it.
>=20
> I think we do care, but it can be a TODO item.

But but but, why not let userspace sort it? And if you're going to
provide the kernel with inode:offset data yourself, you're already well
aware of wtf you're doing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
