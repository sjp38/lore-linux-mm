Date: Tue, 15 Nov 2005 15:00:54 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/5] Light Fragmentation Avoidance V20:
 001_antidefrag_flags
Message-Id: <20051115150054.606ce0df.pj@sgi.com>
In-Reply-To: <20051115164952.21980.3852.sendpatchset@skynet.csn.ul.ie>
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie>
	<20051115164952.21980.3852.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel wrote:
>  #define __GFP_VALID	((__force gfp_t)0x80000000u) /* valid GFP flags */
>  
> +/*
> + * Allocation type modifier
> + * __GFP_EASYRCLM: Easily reclaimed pages like userspace or buffer pages
> + */
> +#define __GFP_EASYRCLM   0x80000u  /* User and other easily reclaimed pages */
> +

How about fitting the style (casts, just one line) of the other flags,
so that these added six lines become instead just the one line:

   #define __GFP_EASYRCLM   ((__force gfp_t)0x80000u)  /* easily reclaimed pages */

(Yeah - it was probably me that asked for -more- comments sometime in
the past - consistency is not my strong suit ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
