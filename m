Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 61BF16B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:43:44 -0400 (EDT)
Date: Wed, 20 Mar 2013 14:43:41 -0400 (EDT)
Message-Id: <20130320.144341.680730923044605208.davem@davemloft.net>
Subject: Re: [patch 2/5] sparse-vmemmap: specify vmemmap population range
 in bytes
From: David Miller <davem@davemloft.net>
In-Reply-To: <1363802612-32127-3-git-send-email-hannes@cmpxchg.org>
References: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
	<1363802612-32127-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: x86@kernel.org, akpm@linux-foundation.org, ben@decadent.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 20 Mar 2013 14:03:29 -0400

> The sparse code, when asking the architecture to populate the vmemmap,
> specifies the section range as a starting page and a number of pages.
> 
> This is an awkward interface, because none of the arch-specific code
> actually thinks of the range in terms of 'struct page' units and
> always translates it to bytes first.
> 
> In addition, later patches mix huge page and regular page backing for
> the vmemmap.  For this, they need to call vmemmap_populate_basepages()
> on sub-section ranges with PAGE_SIZE and PMD_SIZE in mind.  But these
> are not necessarily multiples of the 'struct page' size and so this
> unit is too coarse.
> 
> Just translate the section range into bytes once in the generic sparse
> code, then pass byte ranges down the stack.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Boot tested on sparc64:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
