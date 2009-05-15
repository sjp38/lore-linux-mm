Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CF4F76B0093
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:37:48 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so797080rvb.26
        for <linux-mm@kvack.org>; Thu, 14 May 2009 18:38:23 -0700 (PDT)
Date: Fri, 15 May 2009 10:38:18 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of
 no swap space V4
Message-Id: <20090515103818.2c46d48a.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Adnrew. 

Please, drop my previous version and merge this. 
This versoin can enhance code size and performance by GCC code optimization.
If you wnat to know it detail, please, reference to Johannes Weiner's saying in V3 thread.

Changelog since V4
 o Make to check nr_swap_pages at first. - by Hannes's advise
  o It can reduce text size and increase performance a litte bit by GCC code optimization.

Changelog since V3
 o Remove can_reclaim_anon.
 o Add nr_swap_page > 0 in only shrink_zone - By Rik's advise.
 o Change patch description.

Changelog since V2
 o Add new function - can_reclaim_anon : it tests anon_list can be reclaim.

Changelog since V1
 o Use nr_swap_pages <= 0 in shrink_active_list to prevent scanning  of active anon list.

Now shrink_zone can deactivate active anon pages even if we don't have a swap device.
Many embedded products don't have a swap device. So the deactivation of anon pages is unnecessary.

This patch prevents unnecessary deactivation of anon lru pages.
But, it doesn't prevent aging of anon pages to swap out.

Thanks for good review. Rik,Kosaki and Hannes.
