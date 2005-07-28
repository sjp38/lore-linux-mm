Date: Wed, 27 Jul 2005 18:31:34 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch] mm: Ensure proper alignment for node_remap_start_pfn
Message-ID: <20050728013134.GB23923@localhost.localdomain>
References: <20050728004241.GA16073@localhost.localdomain> <20050727181724.36bd28ed.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050727181724.36bd28ed.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 27, 2005 at 06:17:24PM -0700, Andrew Morton wrote:
> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> >
> > While reserving KVA for lmem_maps of node, we have to make sure that
> > node_remap_start_pfn[] is aligned to a proper pmd boundary.
> > (node_remap_start_pfn[] gets its value from node_end_pfn[])
> > 
> 
> What are the effects of not having this patch applied?  Does someone's
> computer crash, or what?

Yes, it does cause a crash.

Thanks,
Kiran
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
