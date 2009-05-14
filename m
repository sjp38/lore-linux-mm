Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8315C6B01DB
	for <linux-mm@kvack.org>; Thu, 14 May 2009 12:31:01 -0400 (EDT)
Date: Thu, 14 May 2009 09:30:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in
 case of no swap space V3
Message-Id: <20090514093050.43472421.akpm@linux-foundation.org>
In-Reply-To: <20090514231555.f52c81eb.minchan.kim@gmail.com>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009 23:15:55 +0900
MinChan Kim <minchan.kim@gmail.com> wrote:

> Now shrink_zone can deactivate active anon pages even if we don't have a swap device. 
> Many embedded products don't have a swap device. So the deactivation of anon pages is unnecessary. 

Does shrink_list() need to scan the anon LRUs at all if there's no swap
online?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
