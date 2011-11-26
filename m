Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D6C226B002D
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:26:53 -0500 (EST)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 25 Nov 2011 21:26:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAQ2QmK1269354
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:26:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAQ2QlGs024569
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:26:48 -0500
Date: Sat, 26 Nov 2011 07:55:36 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 9/30] uprobes: Background page replacement.
Message-ID: <20111126022536.GB3291@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
 <1322232886.2535.7.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322232886.2535.7.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

* Peter Zijlstra <peterz@infradead.org> [2011-11-25 15:54:46]:

> On Fri, 2011-11-18 at 16:38 +0530, Srikar Dronamraju wrote:
> > +static int read_opcode(struct mm_struct *mm, unsigned long vaddr,
> > +                                               uprobe_opcode_t *opcode)
> > +{
> > +       struct page *page;
> > +       void *vaddr_new;
> > +       int ret;
> > +
> > +       ret = get_user_pages(NULL, mm, vaddr, 1, 0, 0, &page, NULL);
> > +       if (ret <= 0)
> > +               return ret;
> > +
> > +       lock_page(page);
> > +       vaddr_new = kmap_atomic(page);
> > +       vaddr &= ~PAGE_MASK;
> 
> BUG_ON(vaddr + uprobe_opcode_sz >= PAGE_SIZE);
> 

Okay, will add BUG_ON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
