Date: Sat, 15 Oct 2005 19:52:13 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8] Fragmentation Avoidance V17
Message-Id: <20051015195213.44e0dabb.pj@sgi.com>
In-Reply-To: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, jschopp@austin.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel wrote:
> +#define __GFP_USER       0x80000u  /* User and other easily reclaimed pages */
> +#define __GFP_KERNRCLM   0x100000u /* Kernel page that is reclaimable */

Sorry, but that __GFP_USER name is still sticking in my craw.

I won't try to reopen my quest to get it named __GFP_REALLY_REALLY_EASY_RCLM
or whatever it was, but instead will venture on a new quest.

Can we get the 'RCLM' in there.  Especially since this term appears
naked in such code as:

> -				page = alloc_page(GFP_HIGHUSER);
> +				page = alloc_page(GFP_HIGHUSER|__GFP_USER);

where it is not at all obvious to the reader of this file (fs/exec.c)
that the __GFP_USER term is commenting on the reclaim behaviour of
the page to be allocated.

I'd be happier with:

> +#define __GFP_USERRCLM    0x80000u /* User and other easily reclaimed pages */
> +#define __GFP_KERNRCLM   0x100000u /* Kernel page that is reclaimable */

and:

> -				page = alloc_page(GFP_HIGHUSER);
> +				page = alloc_page(GFP_HIGHUSER|__GFP_USERRCLM);

Also the bold assymetry of these two #defines seems to be without motivation,
one with the 'RCLM', and the other with '    ' four spaces.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
