Date: Wed, 28 Jan 2004 13:44:25 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm/vmscan.c:shrink_list(): check PageSwapCache() after
 add_to_swap()
Message-Id: <20040128134425.0c00fb2f.akpm@osdl.org>
In-Reply-To: <16407.59031.17836.961587@laputa.namesys.com>
References: <16407.59031.17836.961587@laputa.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <Nikita@Namesys.COM> wrote:
>
> Hello,
> 
> shrink_list() checks PageSwapCache() before calling add_to_swap(), this
> means that anonymous page that is going to be added to the swap right
> now these checks return false and:
> 
>  (*) it will be unaccounted for in nr_mapped, and
> 
>  (*) it won't be written to the swap if gfp_flags include __GFP_IO but
>      not __GFP_FS.
> 
> (Both will happen only on the next round of scanning.)

OK.  Does it make a measurable change in any benchmarks?

> Patch below just moves may_enter_fs initialization down. I am not sure
> about (*nr_mapped) increase though.

nr_mapped seems OK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
