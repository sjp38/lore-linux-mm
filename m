Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E563B9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 00:17:43 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8L4EHWG026868
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:14:17 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8L4HYof141866
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:17:34 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8L4HWdE014328
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:17:34 -0600
Date: Wed, 21 Sep 2011 09:33:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20110921040344.GD6568@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
 <20110920170310.GB27959@stefanha-thinkpad.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110920170310.GB27959@stefanha-thinkpad.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Stefan Hajnoczi <stefanha@linux.vnet.ibm.com> [2011-09-20 18:03:10]:

> On Tue, Sep 20, 2011 at 05:30:40PM +0530, Srikar Dronamraju wrote:
> > +static void build_probe_list(struct inode *inode, struct list_head *head)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct rb_node *n;
> > +	unsigned long flags;
> > +
> > +	n = uprobes_tree.rb_node;
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> 
> Not sure whether grabbing root.rb_node outside the spinlock is safe?  If
> the tree is rotated on another CPU you could catch and out-of-date node?


Agree that its better to access the node in the spinlock.
Shall correct this.
 
> > +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> > +		struct inode *inode)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct rb_node *n;
> > +	unsigned long flags;
> > +
> > +	n = uprobes_tree.rb_node;
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> 
> Same here.

Okay.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
