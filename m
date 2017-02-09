Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16D216B0389
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 07:22:30 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id kq3so462786wjc.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:22:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15si5981585wmj.55.2017.02.09.04.22.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 04:22:29 -0800 (PST)
Date: Thu, 9 Feb 2017 13:22:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v2] mm: vmpressure: fix sending wrong events on
 underflow
Message-ID: <20170209122227.GH10257@dhcp22.suse.cz>
References: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
 <20170209121057.GF10257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209121057.GF10257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 09-02-17 13:10:57, Michal Hocko wrote:
> On Thu 09-02-17 17:29:36, Vinayak Menon wrote:
> > At the end of a window period, if the reclaimed pages
> > is greater than scanned, an unsigned underflow can
> > result in a huge pressure value and thus a critical event.
> > Reclaimed pages is found to go higher than scanned because
> > of the addition of reclaimed slab pages to reclaimed in
> > shrink_node without a corresponding increment to scanned
> > pages. Minchan Kim mentioned that this can also happen in
> > the case of a THP page where the scanned is 1 and reclaimed
> > could be 512.
> > 
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I would prefer the fixup in vmpressure() as already mentioned but this
> should work as well.

Btw. I guess this should be good to mark for stable. Reclaiming THP is
not all that rare (even though we try to avoid anon reclaim as much as
possible) and hitting critical events can lead to disruptive actions to
early.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
