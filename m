Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8947D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:02:13 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r97so16136626lfi.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 13:02:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o9si16310393wmi.136.2016.07.18.13.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 13:02:12 -0700 (PDT)
Date: Mon, 18 Jul 2016 16:02:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] Follow-up fixes to node-lru series v3
Message-ID: <20160718200205.GA27499@cmpxchg.org>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The v3 is a bit misleading. It's on top of, not instead of, the v2
series with the same name sent out previously. We need both series.

On Mon, Jul 18, 2016 at 03:50:23PM +0100, Mel Gorman wrote:
> This is another round of fixups to the node-lru series. The most important
> patch is the last one which deals with a highmem accounting issue.
> 
>  include/linux/mm_inline.h |  8 ++------
>  mm/vmscan.c               | 25 +++++++++++--------------
>  2 files changed, 13 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
