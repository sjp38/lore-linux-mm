Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 18FBF6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 16:03:51 -0400 (EDT)
Message-ID: <4C7ABD14.9050207@redhat.com>
Date: Sun, 29 Aug 2010 16:03:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap
 system
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com> <AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>
In-Reply-To: <AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 08/29/2010 01:45 PM, Ying Han wrote:

> There are few other places in vmscan where we check nr_swap_pages and
> inactive_anon_is_low. Are we planning to change them to use
> total_swap_pages
> to be consistent ?

If that makes sense, maybe the check can just be moved into
inactive_anon_is_low itself?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
