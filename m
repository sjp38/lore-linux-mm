Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDA436B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 02:32:33 -0400 (EDT)
Received: by ywh41 with SMTP id 41so5856916ywh.23
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 23:32:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	 <4A8B7508.4040001@vflare.org>
	 <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
Date: Wed, 19 Aug 2009 15:24:54 +0900
Message-ID: <18eba5a10908182324x45261d06y83e0f042e9ee6b20@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: =?UTF-8?B?7Jqw7Lap6riw?= <chungki.woo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Thank you very much for replys.

But I think it seems not to relate with stale data problem in compcache.
My question was why last chance to allocate memory was failed.
When OOM killer is executed, memory state is not a condition to
execute OOM killer.
Specially, there are so many pages of order 0. And allocating order is zero.
I think that last allocating memory should have succeeded.
That's my worry.

-----------------------------------------------------------------------------------------------------------------------------------------------
      page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
<== this is last chance
                           zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
<== uses ALLOC_WMARK_HIGH
      if (page)
      goto got_pg;

      out_of_memory(zonelist, gfp_mask, order);
      goto restart;
-----------------------------------------------------------------------------------------------------------------------------------------------

> Let me have a question.
> Now the system has 79M as total swap.
> It's bigger than system memory size.
> Is it possible in compcache?
> Can we believe the number?

Yeah, It's possible. 79Mbyte is data size can be swap.
It's not compressed data size. It's just original data size.

Thanks,
Minchan, Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
