Date: Fri, 18 May 2007 11:24:00 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070518102359.GA7658@infradead.org>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 12:37:06AM -0700, akpm@linux-foundation.org wrote:
> +What:	filemap_nopage, filemap_populate
> +When:	April 2007
> +Why:	These legacy interfaces no longer have any callers in the kernel and
> +	any functionality provided can be provided with filemap_fault. The
> +	removal schedule is short because they are a big maintainence burden
> +	and have some bugs.
> +Who:	Nick Piggin <npiggin@suse.de>
> +
> +---------------------------
> +
> +What:	vm_ops.populate, install_page
> +When:	April 2007
> +Why:	These legacy interfaces no longer have any callers in the kernel and
> +	any functionality provided can be provided with vm_ops.fault.
> +Who:	Nick Piggin <npiggin@suse.de>

There is no point to keep this around at all.  It's not a removal of
functionality but an interface change.  Please just kill that and make
people update their code.

> +What:	vm_ops.nopage
> +When:	February 2008, provided in-kernel callers have been converted
> +Why:	This interface is replaced by vm_ops.fault, but it has been around
> +	forever, is used by a lot of drivers, and doesn't cost much to
> +	maintain.
> +Who:	Nick Piggin <npiggin@suse.de>

This is the kind of thing deprecation makes sense for.  Let's see if we
actually get it done in time, for some reason these staged conversion
always seem to take longer than envisioned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
