Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57D179000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:43:04 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8KFh1S3030070
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 15:43:01 GMT
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KFh1ne1974272
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 16:43:01 +0100
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KFgxve015317
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 09:43:01 -0600
Date: Tue, 20 Sep 2011 16:42:59 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to
 insert, find, delete uprobes
Message-ID: <20110920154259.GA25610@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 20, 2011 at 05:29:49PM +0530, Srikar Dronamraju wrote:
> +static void delete_uprobe(struct uprobe *uprobe)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&uprobes_treelock, flags);
> +	rb_erase(&uprobe->rb_node, &uprobes_tree);
> +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> +	put_uprobe(uprobe);
> +	iput(uprobe->inode);

Use-after-free when put_uprobe() kfrees() the uprobe?

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
