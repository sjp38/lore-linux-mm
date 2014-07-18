Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id BBDE56B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:50:43 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so4500918wes.1
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 05:50:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si3504243wib.72.2014.07.18.05.50.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 05:50:32 -0700 (PDT)
Date: Fri, 18 Jul 2014 13:50:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/3] mm: vmscan: rework compaction-ready signaling in
 direct reclaim fix
Message-ID: <20140718125018.GO10819@suse.de>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
 <1405344049-19868-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405344049-19868-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 14, 2014 at 09:20:47AM -0400, Johannes Weiner wrote:
> As per Mel, replace out label with breaks from the loop.
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
