Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C78126B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:51:09 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so5481714pab.32
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:51:09 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gw6si20504722pac.208.2014.06.22.23.51.07
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 23:51:08 -0700 (PDT)
Date: Mon, 23 Jun 2014 15:51:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 4/4] mm: vmscan: move swappiness out of scan_control
Message-ID: <20140623065141.GD15594@bbox>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403282030-29915-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 12:33:50PM -0400, Johannes Weiner wrote:
> Swappiness is determined for each scanned memcg individually in
> shrink_zone() and is not a parameter that applies throughout the
> reclaim scan.  Move it out of struct scan_control to prevent
> accidental use of a stale value.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
