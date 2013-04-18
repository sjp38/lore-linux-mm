Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 5AC356B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 11:17:43 -0400 (EDT)
Date: Thu, 18 Apr 2013 08:16:50 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
Message-ID: <20130418151650.GH2018@cmpxchg.org>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
 <1365710278-6807-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365710278-6807-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 08:57:54PM +0100, Mel Gorman wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
