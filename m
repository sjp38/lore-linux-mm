Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFCAD8D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:38:33 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2EHVuLg019779
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:31:56 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EHcRDK122048
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:38:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EHcQEr004960
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:38:27 -0600
Date: Mon, 14 Mar 2011 23:02:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110314173238.GR24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
 <1300118433.9910.118.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300118433.9910.118.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Steven Rostedt <rostedt@goodmis.org> [2011-03-14 12:00:33]:

> On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> > +/* Returns 0 if it can install one probe */
> > +int register_uprobe(struct inode *inode, loff_t offset,
> > +                               struct uprobe_consumer *consumer)
> > +{
> > +       struct prio_tree_iter iter;
> > +       struct list_head tmp_list;
> > +       struct address_space *mapping;
> > +       struct mm_struct *mm, *tmpmm;
> > +       struct vm_area_struct *vma;
> > +       struct uprobe *uprobe;
> > +       int ret = -1;
> > +
> > +       if (!inode || !consumer || consumer->next)
> > +               return -EINVAL;
> > +       uprobe = uprobes_add(inode, offset);
> 
> What happens if uprobes_add() returns NULL?
> 
Right again, I should have added a check to see if uprobes_add
hasnt returned NULL.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
