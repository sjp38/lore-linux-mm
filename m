Date: Mon, 17 Oct 2005 06:31:31 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-ID: <20051017113131.GA30898@lnx-holt.americas.sgi.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051014213038.GA7450@kroah.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Robin Holt <holt@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com, Dave Hansen <haveblue@us.ibm.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > +EXPORT_SYMBOL(get_one_pte_map);
> 
> EXPORT_SYMBOL_GPL() ?

Not sure why it would fall that way.  Looking at the directory,
I get:

[holt@lnx-holt mm]$ grep -c 'EXPORT_SYMBOL(' *.c | egrep -v ":0$"
bootmem.c:1
filemap.c:34
fremap.c:1
highmem.c:4
hugetlb.c:1
memory.c:12
mempolicy.c:1
mempool.c:8
mmap.c:10
nommu.c:13
page_alloc.c:15
page-writeback.c:11
readahead.c:2
slab.c:16
sparse.c:1
swap.c:6
swapfile.c:1
swap_state.c:1
truncate.c:2
vmalloc.c:6
vmscan.c:2
[holt@lnx-holt mm]$ grep -c 'EXPORT_SYMBOL_GPL(' *.c | egrep -v ":0$"
filemap_xip.c:5
readahead.c:1
slab.c:1
truncate.c:2


I will happily change it, but that seems inconsistent with the
majority of the exports from that subsystem.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
