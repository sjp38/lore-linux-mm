Date: Mon, 25 Jul 2005 12:46:15 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Question about OOM-Killer
Message-ID: <20050725154615.GA29082@dmt.cnet>
References: <20050725121130.5fed7286.washer@trlp.com> <73740000.1122331287@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73740000.1122331287@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: James Washer <washer@trlp.com>, linux-mm@kvack.org, ak@muc.de
List-ID: <linux-mm.kvack.org>

On Mon, Jul 25, 2005 at 03:41:27PM -0700, Martin J. Bligh wrote:
> Jim, does seem bloody silly to be shooting stuff here, and is
> probably simple to fix ... however, would be useful to see where
> the DMA allocs are coming from as well, any chance you could dump
> a stack backtrace in __alloc_pages when we spec a mask for DMA alloc?
> 
> M.

The stacktrace should probably be in mainline, along with some sort 
of printk ratelimiting...

v2.4 has 

        if (unlikely(vm_gfp_debug))
                dump_stack();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
