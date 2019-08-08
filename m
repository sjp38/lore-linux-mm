Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F69C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 384F021873
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:52:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 384F021873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAC436B0003; Thu,  8 Aug 2019 01:52:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5C6F6B0006; Thu,  8 Aug 2019 01:52:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4BBF6B0007; Thu,  8 Aug 2019 01:52:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 829AE6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 01:52:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q11so54779736pll.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 22:52:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dzMkON2qhgxuXDp9xv9SOiizlU4XQ1qhVLRlqGAALTI=;
        b=Ntk0U2uDrPrHy4XeOLQ9lt4C2sihNVaEhdjVsWFtfdaMgogwQYw5Gfn2c3HSA6YjRT
         v7pJPy8zgxXjBxqqtXw4zby6nHdBRqSkFnsJBTO0t8z5Ep88KUBfWr8zNPms440rJS8r
         L++rcAuofypSP9R6Z7v8neaARLEKoKKfTn799823v1P9Rcn9ixFei0TCWIMZZKVkapMH
         PmBzfnPNABA9FdOeHSna1AY5qRUE6YGsRBajDbPp7ohnZSRLR+kGtl76M5auhTVoORSg
         R7NO91WMAUwYCKuY9ZwpKc+nmLQLnDByciqGMqKNmjx6z5IqVEg5B/MUUv2N+QJf8+gT
         8G5A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXNKwIMnbXfF6b0ujMhKw5giEBY6+rdaO/8bMrfL4cGt8Onu/LN
	yGM4IHay7itPK1EqSHY/PeASlURj2O0MKtBFhpxvWUpCu0HL5J6u16kCahRQabuA+JJyPgaJX2E
	ZFplzSFkSmc99bI1WP8UkT6EnYZB6jJUMBdmxFrNY0Xp/RLHZ9TE+MU3pT+qBtEU=
X-Received: by 2002:a17:90a:d997:: with SMTP id d23mr2142522pjv.84.1565243556227;
        Wed, 07 Aug 2019 22:52:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE/RJMHkbx/sBPqozNFk7ZLJuxdrbrcrAQk8PBZ2cadP+GEUQcawarOZobDHPB70hCY5pW
X-Received: by 2002:a17:90a:d997:: with SMTP id d23mr2142479pjv.84.1565243555503;
        Wed, 07 Aug 2019 22:52:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565243555; cv=none;
        d=google.com; s=arc-20160816;
        b=emDoKp8grxuruhcnm0mjIkyjv0AEW1MgAdx5MwaomkEknR9LgzvtkZ3kW3jahbdDQV
         UPczxu/tYErUktKe8+aExhNgOOfDSgEDmXyNIYSmByYwt5nPJEw2OEXg97SddI/W/xoT
         Yrzkpuube7JTbqSWIXvZp4Iqx5GODZzSnqySHnOhvRl4kwqEFe8igP77K3XjZB8PDDJR
         hMWvdNGA2Mvfa2BWcP5kUMLbP7Ei/vtqREgsnrYrQy41GT2uJZlKAJBupO3HngqLSLGL
         0xWRFx1EUgjIzXe7g8YxOglMz8OCTR1VaVwvgDA3sNZiMq5kSYmN2DnezA4sT1HzEcrY
         C48A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dzMkON2qhgxuXDp9xv9SOiizlU4XQ1qhVLRlqGAALTI=;
        b=L4EY98GSKSyu13Lh9RdcpIf00zPqt3jpFgmfhyDSQ3qnvvbLzFHKKbf1iVFI9SkBfi
         OGRDxTUDaQ/R8H9dc/xRu1yoKK4rtkxHiL2p+MXJIH+w4Hnw7eGcqE4wwXiK6sMNmaRV
         6u54Ah+dTvDSqKqwA6HfKZL212UQVrahrFNaNqcdPbr3JBHi2/OuqU+ug0CnS6Fy+aja
         rakSWsALDJUrS+LI23c0wStj45bLIWbFFh4QJ9Wkt1N/cgMKRkfrEFjh0xhXN6ENks0u
         3Wtgc3DDEd6PKmWSNZv60mLrXW99MYUzB+hhV+GmiXUsEeHej/kXCjSJTRMEcKsJqxZj
         c2WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id a1si1067257pjs.58.2019.08.07.22.52.35
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 22:52:35 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 26295362962;
	Thu,  8 Aug 2019 15:52:32 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvbKf-0000HC-Hf; Thu, 08 Aug 2019 15:51:25 +1000
Date: Thu, 8 Aug 2019 15:51:25 +1000
From: Dave Chinner <david@fromorbit.com>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190808055125.GV7777@dread.disaster.area>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
 <20190807220817.GN7777@dread.disaster.area>
 <20190807235534.GK2739@techsingularity.net>
 <20190808003025.GU7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808003025.GU7777@dread.disaster.area>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=BNQjUj_GC9DrHHjaN18A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:30:25AM +1000, Dave Chinner wrote:
> On Thu, Aug 08, 2019 at 12:55:34AM +0100, Mel Gorman wrote:
> > On Thu, Aug 08, 2019 at 08:08:17AM +1000, Dave Chinner wrote:
> > > On Wed, Aug 07, 2019 at 04:03:16PM +0100, Mel Gorman wrote:
> > > > On Wed, Aug 07, 2019 at 11:30:56AM +0200, Michal Hocko wrote:
> > > > The boosting was not intended to target THP specifically -- it was meant
> > > > to help recover early from any fragmentation-related event for any user
> > > > that might need it. Hence, it's not tied to THP but even with THP
> > > > disabled, the boosting will still take effect.
> > > > 
> > > > One band-aid would be to disable watermark boosting entirely when THP is
> > > > disabled but that feels wrong. However, I would be interested in hearing
> > > > if sysctl vm.watermark_boost_factor=0 has the same effect as your patch.
> > > 
> > > <runs test>
> > > 
> > > Ok, it still runs it out of page cache, but it doesn't drive page
> > > cache reclaim as hard once there's none left. The IO patterns are
> > > less peaky, context switch rates are increased from ~3k/s to 15k/s
> > > but remain pretty steady.
> > > 
> > > Test ran 5s faster and  file rate improved by ~2%. So it's better
> > > once the page cache is largerly fully reclaimed, but it doesn't
> > > prevent the page cache from being reclaimed instead of inodes....
> > > 
> > 
> > Ok. Ideally you would also confirm the patch itself works as you want.
> > It *should* but an actual confirmation would be nice.
> 
> Yup, I'll get to that later today.

Looks good, does what it says on the tin.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com

