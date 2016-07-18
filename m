Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B86A16B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 12:13:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so62218300wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:13:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id aw2si1959225wjc.40.2016.07.18.09.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 09:13:40 -0700 (PDT)
Date: Mon, 18 Jul 2016 12:13:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm, vmscan: Release/reacquire lru_lock on pgdat
 change
Message-ID: <20160718161336.GB16465@cmpxchg.org>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
 <1468853426-12858-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468853426-12858-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:25PM +0100, Mel Gorman wrote:
> With node-lru, the locking is based on the pgdat. As Minchan pointed
> out, there is an opportunity to reduce LRU lock release/acquire in
> check_move_unevictable_pages by only changing lock on a pgdat change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
