Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 031988D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 21:29:50 -0400 (EDT)
Date: Fri, 1 Apr 2011 21:29:09 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 6/26]  6: Uprobes:
	register/unregister probes.
Message-ID: <20110402012909.GA2779@fibrous.localdomain>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6> <20110402002633.GA13277@fibrous.localdomain> <20110402005353.GA17416@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110402005353.GA17416@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Apr 02, 2011 at 06:23:53AM +0530, Srikar Dronamraju wrote:
> > > +
> > > +		mm = vma->vm_mm;
> > > +		if (!valid_vma(vma)) {
> > > +			mmput(mm);
> > > +			continue;
> > > +		}
> > > +
> > > +		vaddr = vma->vm_start + offset;
> > > +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > 
> > What happens here when someone passes an offset that is out of bounds
> > for the vma?  Looks like we could oops when the kernel tries to set a
> > breakpoint.  Perhaps check wrt ->vm_end?
> > 
> 
> If the offset is wrong, install_uprobe will fail, since
> grab_cache_page() should not be able to find that page for us.
> And hence we return gracefully.

Hummm.  But grab_cache_page() just wraps find_or_create_page(), so I don't
think it will do what you want.


> I will surely test this case and I am happy to add a check for
> vm_end.

Thanks!


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
