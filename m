Date: Sun, 23 Apr 2006 16:12:09 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [rfc][patch] radix-tree: small data structure
Message-ID: <20060423211209.GW15445@waste.org>
References: <444BA0A9.3080901@yahoo.com.au> <444BA150.7040907@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <444BA150.7040907@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <Linux-Kernel@Vger.Kernel.ORG>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 24, 2006 at 01:46:24AM +1000, Nick Piggin wrote:
> Nick Piggin wrote:
> >With the previous patch, the radix_tree_node budget on my 64-bit
> >desktop is cut from 20MB to 10MB. This patch should cut it again
> >by nearly a factor of 4 (haven't verified, but 98ish % of files
> >are under 64K).
> >
> >I wonder if this would be of any interest for those who enable
> >CONFIG_BASE_SMALL?
> 
> Bah, wrong patch.

I like it.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
