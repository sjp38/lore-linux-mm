Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E8E9E6B0096
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:45:22 -0400 (EDT)
Message-ID: <4A0CC951.6070003@redhat.com>
Date: Thu, 14 May 2009 21:45:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
 of no swap space V4
References: <20090515103818.2c46d48a.minchan.kim@gmail.com>
In-Reply-To: <20090515103818.2c46d48a.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:

> This patch prevents unnecessary deactivation of anon lru pages.
> But, it doesn't prevent aging of anon pages to swap out.

>  Signed-off-by: barrios <minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
