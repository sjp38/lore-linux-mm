Date: Fri, 28 Oct 2005 15:29:15 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028132915.GH5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <200510281303.56688.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510281303.56688.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Jeff Dike <jdike@addtoit.com>, Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 28, 2005 at 01:03:56PM +0200, Blaisorblade wrote:
> and when I'll get the time to finish the remap_file_pages changes* for UML to 
> use it, UML will _require_ this to be implemented too.

Would it be possible to make remap_file_pages an option? I mean, if
you're doing a xen-like usage, remap_file_pages is a good thing, but if
you're in a multiuser system and you want to be friendly when the system
swaps, remap_file_pages can hurt. The worst is when remap_file_pages
covers huge large areas, that forces the vm to walk all the ptes for the
whole vma region for each page that could be mapped by that region.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
