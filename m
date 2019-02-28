Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE44AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:33:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B52BC20854
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:33:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B52BC20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 558DE8E0003; Thu, 28 Feb 2019 06:33:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E1B08E0001; Thu, 28 Feb 2019 06:33:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D18D8E0003; Thu, 28 Feb 2019 06:33:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D78E18E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:33:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x47so8260631eda.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:33:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zlRV+Xpewi2YGgLpwspHNg91ydUHHy4Vmzi7Nw6lK+k=;
        b=VD0mt1U27xT41P4WRYzi+22Aaydz5FgVJPJ31SHljX1pk23hURYXk1cLOQnsEouYSc
         xRqqRide3Y2lUkmQhbZUSWU+A874TO2j7VBQKHf7tRuZlD9AKoCtJWu663UHGpb8TWO5
         JMg8DZwHTTadNHbz6GwEXyFKys5i0pp5h1TtjDdQJhLd2MjcYLgikUJyXpth5XCoZLYa
         FUH5UcYPmTkIFR0jzKSYIWwirptSK03McD9S/CxAUOoq0ctCFsH9CJ0op/UX5WURlKZS
         nzUuT/QMZAZeHVwJlbP6vtYpr1lJJMQdPyOPsU1/gCYtLHkBQzKmuTl3tilm2u2oB+w4
         drOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZN5JK9tBhBd9alBoOjse0RIgRpzpYS5vfokODFFgO+rlXusSC9
	k7NYDICZT6v+qRa1kY2d0R9XeYSjPZCp2s4sP3fz0ass+YMHuo3yZk/auLFV/KMPNDrCnf1SRbo
	IjckSKj84/0Y4OjuhK9NV1BYw0KmBA17U8nyXWRpznFNylLtHvCS2bz0e1yqg2EqLxg==
X-Received: by 2002:a17:906:52d5:: with SMTP id w21mr5026709ejn.172.1551353586443;
        Thu, 28 Feb 2019 03:33:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuJ8Z4J/LvyIj5F9OhFD0HVOJsqhw/QjH1kUKM8WqYsKqJ6x6Sehd8lIACRPzORBmLKEnf
X-Received: by 2002:a17:906:52d5:: with SMTP id w21mr5026666ejn.172.1551353585656;
        Thu, 28 Feb 2019 03:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353585; cv=none;
        d=google.com; s=arc-20160816;
        b=Eqli+q7S7YVgTEYRrWhTFNzX5fIIk5svLsqWY6yP2tmzGa1liA/7fwA7aLm8TeTaQt
         9dZ7b10/wd5owPN7Jib5K45R0rVVk0henOufwaQPwjMEQB2pVRWUzaMKSsh5ollHmCB7
         s5D0O7GyJ4GceglJXaxVhdsYUEhxNRvLOfHpm79s9P6CLUkE/kRFyyB7h0JntI/hjd1J
         wH13sm1qqA8Yy7aoV2Qn6N1Z3LxDLtc10Uhzgdk4VZ7kfiqfp+r+MlcrumCt663XK/6g
         9vnUWzHw0+qQBdMmP5b4VyHgg9bxE2PdmPHx4OQ/LVxAdIVxmvrfui7e4UnzEaRbHc+/
         tjiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zlRV+Xpewi2YGgLpwspHNg91ydUHHy4Vmzi7Nw6lK+k=;
        b=pFmBQpYBL+BMTLgUoKd8z4dXsFnX4rHab/JFiy68B2GnAuaW/Hwh++HIoepmATGeen
         LqWPXBbMWPgEtCc/jmH0v2VvARKa0UMqogMICfN0x/xlYXNUWt03zQPWOi4J8XuoJrw9
         NSJcLn+S20EOys0SJveKvgffd/wFFkvsfJNSGDCqT3QIEPF4cCt330iujl6FJE3w2umf
         kJKLf7vej0pqh9bYlqkVmYcDTWmjs4EFqzc2FRP6aK/qNFW9NIUa/wGVgxh4tDhkpLlV
         PRKeYyWXd+iUNzOAK5HP5UOcSUAMV93kBWmH59MjgwUKp56v4ogIyHeX05Q2oYRQTvM2
         q4tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id y15si4262475edj.12.2019.02.28.03.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 03:33:05 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 46C59B87B0
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:33:05 +0000 (GMT)
Received: (qmail 11447 invoked from network); 28 Feb 2019 11:33:05 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 28 Feb 2019 11:33:05 -0000
Date: Thu, 28 Feb 2019 11:33:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
Message-ID: <20190228113303.GE9565@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190228083329.31892-2-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 11:33:27AM +0300, Andrey Ryabinin wrote:
> We have common pattern to access lru_lock from a page pointer:
> 	zone_lru_lock(page_zone(page))
> 
> Which is silly, because it unfolds to this:
> 	&NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]->zone_pgdat->lru_lock
> while we can simply do
> 	&NODE_DATA(page_to_nid(page))->lru_lock
> 
> Remove zone_lru_lock() function, since it's only complicate things.
> Use 'page_pgdat(page)->lru_lock' pattern instead.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

