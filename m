Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 839126B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 12:14:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so62084954wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:14:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qw18si1961567wjb.158.2016.07.18.09.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 09:14:07 -0700 (PDT)
Date: Mon, 18 Jul 2016 12:14:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm, vmstat: remove zone and node double accounting
 by approximating retries -fix
Message-ID: <20160718161402.GC16465@cmpxchg.org>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
 <1468853426-12858-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468853426-12858-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:26PM +0100, Mel Gorman wrote:
> As pointed out by Vlastimil, the atomic_add() functions are already assumed
> to be able to handle negative numbers. The atomic_sub handling was wrong
> anyway but this patch fixes it unconditionally.
> 
> This is a fix to the mmotm patch
> mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
