Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D112F9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 12:26:12 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 12/26]   Uprobes: Handle breakpoint and
 Singlestep
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Sep 2011 18:25:22 +0200
In-Reply-To: <20110926160144.GC13535@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120221.25326.74714.sendpatchset@srdronam.in.ibm.com>
	 <1317045553.1763.23.camel@twins>
	 <20110926160144.GC13535@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317054322.1763.31.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-09-26 at 21:31 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-09-26 15:59:13]:
>=20
> > On Tue, 2011-09-20 at 17:32 +0530, Srikar Dronamraju wrote:
> > > 						Hence provide some extra
> > > + * time (by way of synchronize_sched() for breakpoint hit threads to=
 acquire
> > > + * the uprobes_treelock before the uprobe is removed from the rbtree=
.=20
> >=20
> > 'Some extra time' doesn't make me all warm an fuzzy inside, but instead
> > screams we fudge around a race condition.
>=20
> The extra time provided is sufficient to avoid the race. So will modify
> it to mean "sufficient" instead of "some".  =20
>=20
> Would that suffice?

Much better, for extra point, explain why its sufficient as well ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
