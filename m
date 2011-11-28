Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7570E6B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:58:19 -0500 (EST)
Message-ID: <1322510277.2921.164.camel@twins>
Subject: Re: [PATCH RFC 0/5] uprobes: kill xol vma
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 20:57:57 +0100
In-Reply-To: <20111128190614.GA4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111128190614.GA4602@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Mon, 2011-11-28 at 20:06 +0100, Oleg Nesterov wrote:
>=20
> On top of this series, not for inclusion yet, just to explain what
> I mean. May be someone can test it ;)
>=20
> This series kills xol_vma. Instead we use the per_cpu-like xol slots.
>=20
> This is much more simple and efficient. And this of course solves
> many problems we currently have with xol_vma.
>=20
> For example, we simply can not trust it. We do not know what actually
> we are going to execute in UTASK_SSTEP mode. An application can unmap
> this area and then do mmap(PROT_EXEC|PROT_WRITE, MAP_FIXED) to fool
> uprobes.
>=20
> The only disadvantage is that this adds a bit more arch-dependant
> code.
>=20
> The main question, can this work? I know very little in this area.
> And I am not sure if this can be ported to other architectures.

I very much like this approach! I think the provided implementation
might have some issues, but yeah, using fixmaps and a __switch_to_xtra
hook to provide per task slots seems very nice indeed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
