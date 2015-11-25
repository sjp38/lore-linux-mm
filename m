Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 53B5D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:00:24 -0500 (EST)
Received: by wmuu63 with SMTP id u63so134867616wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:00:24 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id b186si5292321wmd.88.2015.11.25.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 04:00:23 -0800 (PST)
Received: by wmuu63 with SMTP id u63so134867088wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:00:23 -0800 (PST)
Date: Wed, 25 Nov 2015 13:00:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151125120021.GA27342@dhcp22.suse.cz>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
> When I tested compaction in low memory condition, I found that
> my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> This stuck last for 1 sec and after then it can escape. More investigation
> shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> so it is stuck for 1 sec.

Wouldn't it be sufficient to use zone_page_state_snapshot in
too_many_isolated?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
