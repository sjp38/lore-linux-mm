Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 480DC6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:30:35 -0400 (EDT)
Date: Mon, 5 Aug 2013 14:30:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/9] mm: zone_reclaim: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130805183028.GA1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:28PM +0200, Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
