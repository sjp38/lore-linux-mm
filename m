Date: Mon, 17 Oct 2005 21:59:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
In-Reply-To: <20051017202501.GB15670@lnx-holt.americas.sgi.com>
Message-ID: <Pine.LNX.4.61.0510172157590.3969@goblin.wat.veritas.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>
 <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com>
 <20051017113131.GA30898@lnx-holt.americas.sgi.com> <1129549312.32658.32.camel@localhost>
 <20051017114730.GC30898@lnx-holt.americas.sgi.com>
 <Pine.LNX.4.61.0510171331090.2993@goblin.wat.veritas.com>
 <20051017151430.GA2564@lnx-holt.americas.sgi.com>
 <Pine.LNX.4.61.0510171644220.4773@goblin.wat.veritas.com>
 <20051017202501.GB15670@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Greg KH <greg@kroah.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Carsten Otte <cotte@de.ibm.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Oct 2005, Robin Holt wrote:
> On Mon, Oct 17, 2005 at 04:59:20PM +0100, Hugh Dickins wrote:
> > Repeating a technical question (sorry, that now seems off-topic!):
> > what do you expect to happen with PROT_WRITE, MAP_PRIVATE?
> 
> That would end up with a MAP_PRIVATE, PROT_WRITE, VM_RESERVED
> mapping.  That does not make sense for this device, so I added
> the following check to mspec_mmap()
> 
>         if ((vma->vm_flags & VM_SHARED) == 0)
>                 return -EINVAL;

Great, that saves us (or at least postpones) some nastiness!

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
