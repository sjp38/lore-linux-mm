Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C8A266B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:49:04 -0500 (EST)
Message-ID: <1322509712.2921.158.camel@twins>
Subject: Re: [PATCH 3/5] uprobes: introduce uprobe_xol_slots[NR_CPUS]
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 20:48:32 +0100
In-Reply-To: <20111128190714.GD4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111128190614.GA4602@redhat.com> <20111128190714.GD4602@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Mon, 2011-11-28 at 20:07 +0100, Oleg Nesterov wrote:
> +       UPROBE_XOL_FIRST_PAGE =3D UPROBE_XOL_LAST_PAGE
> +                             + NR_CPUS * UPROBES_XOL_SLOT_BYTES / PAGE_S=
IZE,=20

I think that wants to be:=20
	+ DIV_ROUND_UP(NR_CPUS * UPROBES_XOL_SLOT_BYTES, PAGE_SIZE);

otherwise you'll end up with 0 pages for UP and the sort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
