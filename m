Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 044E46B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 04:45:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 4so44949940wrc.15
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 01:45:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10si12619594wra.251.2017.07.04.01.45.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 01:45:44 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH stable-only] mm: fix classzone_idx underflow in shrink_zones()
Message-ID: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
Date: Tue, 4 Jul 2017 10:45:43 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Hi,

I realize this is against the standard stable policy, but I see no other
way, because the mainline accidental fix is part of 34+ patch reclaim
rework, that would be absurd to try to backport into stable. The fix is
a one-liner though.

The bug affects at least 4.4.y, and likely also older stable trees that
backported commit 7bf52fb891b6, which itself was a fix for 3.19 commit
6b4f7799c6a5. You could revert the 7bf52fb891b6 backport, but then 32bit
with highmem might suffer from OOM or thrashing.

More details in the changelog itself.

----8<----
