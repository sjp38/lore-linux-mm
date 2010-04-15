Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 32D466B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:04:59 -0400 (EDT)
Message-ID: <4BC6E581.1000604@kernel.org>
Date: Thu, 15 Apr 2010 19:08:01 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>	 <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org>	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>	 <4BC6BE78.1030503@kernel.org>	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>	 <4BC6CB30.7030308@kernel.org> <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
In-Reply-To: <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/15/2010 06:40 PM, Minchan Kim wrote:
>> I'm not an expert on that part of the kernel but isn't
>> alloc_pages_any_node() identical to alloc_pages_exact_node()?  All
> 
> alloc_pages_any_node means user allows allocated pages in any
> node(most likely current node) alloc_pages_exact_node means user
> allows allocated pages in nid node if he doesn't use __GFP_THISNODE.

Ooh, sorry, I meant alloc_pages().  What would be the difference
between alloc_pages_any_node() and alloc_pages()?

>> introducing new API just to weed out invalid usages seems like an
>> overkill.
> 
> It might be.
> 
> It think it's almost same add_to_page_cache and add_to_page_cache_locked.
> If user knows the page is already locked, he can use
> add_to_page_cache_locked for performance gain and code readability
> which we need to lock the page before calling it.

Yeah, if both APIs are necessary at the end of the conversion, sure.
I was just saying that introducing new APIs just to weed out invalid
usages and then later killing the old API would be rather excessive.

I was just wondering whether we could just clean up alloc_pages_node()
users and kill alloc_pages_exact_node().

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
