Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E1816B01EC
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:25:59 -0400 (EDT)
Message-ID: <4A0C5434.3040905@redhat.com>
Date: Thu, 14 May 2009 13:26:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
 of no swap space V3
References: <20090514231555.f52c81eb.minchan.kim@gmail.com> <20090514093050.43472421.akpm@linux-foundation.org>
In-Reply-To: <20090514093050.43472421.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: MinChan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 14 May 2009 23:15:55 +0900
> MinChan Kim <minchan.kim@gmail.com> wrote:
> 
>> Now shrink_zone can deactivate active anon pages even if we don't have a swap device. 
>> Many embedded products don't have a swap device. So the deactivation of anon pages is unnecessary. 
> 
> Does shrink_list() need to scan the anon LRUs at all if there's no swap
> online?

It doesn't.  Get_scan_ratio() will return 0 as the
anon percentage if no swap is online.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
