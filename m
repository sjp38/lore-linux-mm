Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id F2D336B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 05:58:16 -0500 (EST)
Message-ID: <1325847461.2442.4.camel@twins>
Subject: Re: [PATCH v8 3.2.0-rc5 1/9] uprobes: Install and remove
 breakpoints.
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 06 Jan 2012 11:57:41 +0100
In-Reply-To: <20120106061407.GC14946@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
	 <20111216122808.2085.76986.sendpatchset@srdronam.in.ibm.com>
	 <1325695788.2697.3.camel@twins> <20120106061407.GC14946@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 2012-01-06 at 11:44 +0530, Srikar Dronamraju wrote:
>         - consumers for the uprobe is NULL, so mmap_uprobe will not
>           insert new breakpoints which correspond to this uprobe until
>           or unless another consumer gets added for the same probe.
>=20
>         - If a new consumer gets added for this probe, we reuse the
>           uprobe struct.

Ok, and when we install a new 'first' consumer we'll again try and
install all breakpoints ignoring those that were already there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
