Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53C678D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:18:24 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LH4lNQ003835
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:04:47 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LHIAj7120972
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:18:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LHI7gp026730
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:18:10 -0600
Date: Thu, 21 Apr 2011 22:33:55 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 15/26] 15: uprobes: Handing int3 and
 singlestep exception.
Message-ID: <20110421170355.GH10698@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143527.15455.32854.sendpatchset@localhost6.localdomain6>
 <1303220359.8345.1.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303220359.8345.1.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-04-19 15:39:19]:

> On Fri, 2011-04-01 at 20:05 +0530, Srikar Dronamraju wrote:
> > +               probept = uprobes_get_bkpt_addr(regs);
> > +               down_read(&mm->mmap_sem);
> > +               for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +                       if (!valid_vma(vma))
> > +                               continue;
> > +                       if (probept < vma->vm_start || probept > vma->vm_end)
> > +                               continue;
> > +                       u = find_uprobe(vma->vm_file->f_mapping->host,
> > +                                       probept - vma->vm_start);
> > +                       break;
> > +               }
> 
> Why the linear vma walk? Surely the find_vma() suffices since there can
> only be one vma that matches a particular vaddr.


Agree, will incorporate.

-- 
Thanks and Regards
Srikar
> 
> > +               up_read(&mm->mmap_sem); 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
