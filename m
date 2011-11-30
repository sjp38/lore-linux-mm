Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC3C6B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:21:06 -0500 (EST)
Message-ID: <1322670031.2921.286.camel@twins>
Subject: Re: [PATCH RFC 0/5] uprobes: kill xol vma
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 30 Nov 2011 17:20:31 +0100
In-Reply-To: <91601168bd8039233da8d91a07560f20.squirrel@www.firstfloor.org>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111128190614.GA4602@redhat.com>
	 <20111129103040.GF13445@linux.vnet.ibm.com>
	 <20111129182643.GB7339@redhat.com>
	 <91601168bd8039233da8d91a07560f20.squirrel@www.firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Wed, 2011-11-30 at 17:15 +0100, Andi Kleen wrote:
> >  static unsigned char
> > -uprobe_xol_slots[UPROBES_XOL_SLOT_BYTES][NR_CPUS] __page_aligned_bss;
> > +uprobe_xol_slots[NR_CPUS][UPROBES_XOL_SLOT_BYTES] __page_aligned_bss;
>=20
> NR_CPUS arrays are basically always wrong.
>=20
> Use per cpu data.

Doesn't really work here, you'd know if you'd read the patches. What we
could do though is do a UPROBES_XOL_SLOT_BYTES * nr_cpu_ids bootmem
allocation or so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
