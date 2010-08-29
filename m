Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 258476B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 18:26:15 -0400 (EDT)
Message-ID: <4C7ADE7A.2040909@redhat.com>
Date: Sun, 29 Aug 2010 18:26:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap
 system
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>	<AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>	<4C7ABD14.9050207@redhat.com> <AANLkTimjVHp1=Fc35xLnyPb2aa+ew7w1P9DC_0GfhZgY@mail.gmail.com>
In-Reply-To: <AANLkTimjVHp1=Fc35xLnyPb2aa+ew7w1P9DC_0GfhZgY@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 08/29/2010 05:23 PM, Ying Han wrote:
> On Sun, Aug 29, 2010 at 1:03 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 08/29/2010 01:45 PM, Ying Han wrote:
>>
>>> There are few other places in vmscan where we check nr_swap_pages and
>>> inactive_anon_is_low. Are we planning to change them to use
>>> total_swap_pages
>>> to be consistent ?
>>
>> If that makes sense, maybe the check can just be moved into
>> inactive_anon_is_low itself?
>
> That was the initial patch posted, instead we changed to use
> total_swap_pages instead. How this patch looks:

Looks good to me.  It could use a comment along the lines of:

	/*
	 * No sense scanning the anon lists if we have no swap space.
	 */

... and, of course, your signed-off-by :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
