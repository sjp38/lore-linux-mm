Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E05846B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 22:28:54 -0400 (EDT)
Message-ID: <4BECB562.2080200@cesarb.net>
Date: Thu, 13 May 2010 23:28:50 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH] radix-tree: fix radix_tree_prev_hole underflow case
References: <1273802724-3414-1-git-send-email-cesarb@cesarb.net> <20100514021508.GA7810@localhost>
In-Reply-To: <20100514021508.GA7810@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Em 13-05-2010 23:15, Wu Fengguang escreveu:
> On Fri, May 14, 2010 at 10:05:24AM +0800, Cesar Eduardo Barros wrote:
>> radix_tree_prev_hole() used LONG_MAX to detect underflow; however,
>> ULONG_MAX is clearly what was intended, both here and by its only user
>> (count_history_pages at mm/readahead.c).
>
> Good catch, thanks! I actually have a more smart
> radix_tree_prev_hole() that uses ULONG_MAX.

I saw it already ([PATCH 14/16] radixtree: speed up the search for 
hole), but it misses the LONG_MAX in the documentation comment.

> Andrew, fortunately this bug has little impact on readahead.

I agree, if I read it correctly it should only have any impact either 
when very near LONG_MAX or in the unlikely case that there is no hole at 
ULONG_MAX. And even then, the impact should be limited.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
