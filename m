Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 270196B00E8
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:34:13 -0400 (EDT)
Date: Tue, 14 Jun 2011 16:29:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
	probes.
Message-ID: <20110614142959.GC5139@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6> <20110613195701.GA14656@redhat.com> <20110614120023.GB4952@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110614120023.GB4952@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 06/14, Srikar Dronamraju wrote:
>
> * Oleg Nesterov <oleg@redhat.com> [2011-06-13 21:57:01]:
>
> > > +	mutex_lock(&mapping->i_mmap_mutex);
> > > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> >
> > I didn't actually read this patch yet, but this looks suspicious.
> > Why begin == end == 0? Doesn't this mean we are ignoring the mappings
> > with vm_pgoff != 0 ?
> >
> > Perhaps this should be offset >> PAGE_SIZE?
> >
>
> Okay,
> I guess you meant something like this.
>
> 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
>
> where pgoff == offset >> PAGE_SIZE
> Right?

Yes, modulo s/PAGE_SIZE/PAGE_SHIFT. But please double check, I can be
easily wrong ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
