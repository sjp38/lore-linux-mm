Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 49F056B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:47:55 -0500 (EST)
Received: by wmww144 with SMTP id w144so70032832wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:47:54 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id v4si5920268wma.96.2015.11.25.05.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 05:47:54 -0800 (PST)
Received: by wmww144 with SMTP id w144so70032171wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:47:53 -0800 (PST)
Date: Wed, 25 Nov 2015 14:47:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151125134747.GH27283@dhcp22.suse.cz>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151125120021.GA27342@dhcp22.suse.cz>
 <5655BB0A.90000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5655BB0A.90000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 25-11-15 14:43:38, Vlastimil Babka wrote:
> On 11/25/2015 01:00 PM, Michal Hocko wrote:
> > On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
> >> When I tested compaction in low memory condition, I found that
> >> my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> >> This stuck last for 1 sec and after then it can escape. More investigation
> >> shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> >> so it is stuck for 1 sec.
> > 
> > Wouldn't it be sufficient to use zone_page_state_snapshot in
> > too_many_isolated?
> 
> That sounds better than the ad-hoc half-solution, yeah.
> I don't know how performance sensitive the callers are, but maybe it could do a
> non-snapshot check first, and only repeat with _snapshot when it's about to wait
> (the result is true), just to make sure?

I am not sure this is worth bothering. We are in the reclaim which is
not a hot path.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
