Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 918006B003C
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 08:56:10 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so6995871wes.15
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:56:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hc6si23133026wjc.68.2014.06.23.05.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 05:56:06 -0700 (PDT)
Date: Mon, 23 Jun 2014 13:56:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/4] mm: vmscan: remove remains of kswapd-managed
 zone->all_unreclaimable
Message-ID: <20140623125602.GL10819@suse.de>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 12:33:47PM -0400, Johannes Weiner wrote:
> shrink_zones() has a special branch to skip the all_unreclaimable()
> check during hibernation, because a frozen kswapd can't mark a zone
> unreclaimable.
> 
> But ever since 6e543d5780e3 ("mm: vmscan: fix do_try_to_free_pages()
> livelock"), determining a zone to be unreclaimable is done by directly
> looking at its scan history and no longer relies on kswapd setting the
> per-zone flag.
> 
> Remove this branch and let shrink_zones() check the reclaimability of
> the target zones regardless of hibernation state.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
