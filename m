From: Andi Kleen <ak@suse.de>
Subject: Re: numa_maps update
Date: Sat, 4 Mar 2006 05:59:16 +0100
References: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com> <20060304010708.31697f71.akpm@osdl.org>
In-Reply-To: <20060304010708.31697f71.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603040559.16666.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, hugh@veritas.com, linux-mm@kvack.org, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

On Saturday 04 March 2006 10:07, Andrew Morton wrote:
> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > Change the format
> 
> uh-oh.

I guess it's better because it's clearly better than the old format.
But of course it would need to be done before 2.6.16
> 
> > of numa_maps to be more compact and contain additional
> > information that is useful for managing and troubleshooting memory on a NUMA
> > system. Numa_maps can now also support huge pages.
> 
> What will be the userspace impact (ie: breakage) due to this change?

It will at least break the manpages I think. But I suspect/hope no user space
is using it yet because it was only added recently.

> > +	if (file) {
> > +
> > +		seq_printf(m, " file=");
> > +		seq_path(m, file->f_vfsmnt, file->f_dentry, "\n\t");
> > +
> > +	} else if (vma->vm_start <= mm->brk &&
> > +		   vma->vm_end >= mm->start_brk)
> > +
> > +			seq_printf(m, " heap");
> > +
> > +	else if (vma->vm_start <= mm->start_stack &&
> > +		vma->vm_end >= mm->start_stack)
> > +
> > +			seq_printf(m, " stack");
> > +
> > +	if (is_vm_hugetlb_page(vma)) {
> > +
> > +		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
> > +		seq_printf(m, " huge");
> > +
> > +	} else
> 
> What bizarre layout!

The 16 space indents?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
