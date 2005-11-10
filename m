Date: Wed, 9 Nov 2005 16:11:46 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2/4] Hugetlb: Rename find_lock_page to find_or_alloc_huge_page
Message-ID: <20051110001146.GL29402@holomorphy.com>
References: <1131578925.28383.9.camel@localhost.localdomain> <1131579472.28383.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131579472.28383.20.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 09, 2005 at 05:37:52PM -0600, Adam Litke wrote:
> Hugetlb: Rename find_lock_page to find_or_alloc_huge_page

> On Wed, 2005-10-26 at 12:00 +1000, David Gibson wrote:
> - find_lock_huge_page() isn't a great name, since it does extra things
>   not analagous to find_lock_page().  Rename it
>   find_or_alloc_huge_page() which is closer to the mark.
> Original post by David Gibson <david@gibson.dropbear.id.au>
> Version 2: Wed 9 Nov 2005
> 	Split into a separate patch
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Adam Litke <agl@us.ibm.com>

Also innocuous.

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
