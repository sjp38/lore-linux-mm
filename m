Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 248316B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:52:09 -0400 (EDT)
Message-ID: <516776CD.4070109@redhat.com>
Date: Thu, 11 Apr 2013 22:51:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <1365505625-9460-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/09/2013 07:07 AM, Mel Gorman wrote:
> Currently kswapd queues dirty pages for writeback if scanning at an elevated
> priority but the priority kswapd scans at is not related to the number
> of unqueued dirty encountered.  Since commit "mm: vmscan: Flatten kswapd
> priority loop", the priority is related to the size of the LRU and the
> zone watermark which is no indication as to whether kswapd should write
> pages or not.
>
> This patch tracks if an excessive number of unqueued dirty pages are being
> encountered at the end of the LRU.  If so, it indicates that dirty pages
> are being recycled before flusher threads can clean them and flags the
> zone so that kswapd will start writing pages until the zone is balanced.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I like your approach of essentially not writing out from
kswapd if we manage to reclaim well at DEF_PRIORITY, and
doing writeout more and more aggressively if we have to
reduce priority.

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
