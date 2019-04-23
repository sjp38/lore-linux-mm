Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AABEC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 14:35:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47CB021738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 14:35:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47CB021738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA6476B0006; Tue, 23 Apr 2019 10:35:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54876B0007; Tue, 23 Apr 2019 10:35:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1D7C6B0008; Tue, 23 Apr 2019 10:35:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87D896B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:35:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m57so4467846edc.7
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:35:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=k/G2KUsFtfhv1I5sxjAd5L+a3It5LAnKQGLM+DApu38=;
        b=RGGWvHmnrHh8P6/yGpHMJsQACll1dvV+b/sPvOXHi8auWTNkwmqDN8svOQiTHdXOKl
         bE5aEJOXVoUlNgkZiKJtHmkYfnAyS8Nyz0gmRndNxWSMCnmLR5Tmj3wAeiBaTs0kxaJy
         U4HAKObepSFscI4gzh87kDF0ORSb5UsJKzdnfEXqNQViwNtgiRNwtYL4np6GHQorA6OO
         V2fMvC1mCuzHHtNgtU5SCccx39PwncCsdQpOM5KC/+nQFSnIf/h9JRc7FPdsDBLIXI36
         Nev4Wl+TASzKzN/4pU3UlWHI2RDdNZzzy6aGmfrZnp/piATUys6lk4Oih+2NZ0uLckiX
         NpQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUVHfJy8GiOAeeZliN+FFxHc3PXpsj0vZOkOtIIaWs/DfFypw17
	fkqWKFdhgcW9pozA4UmSj1sDkX4d7V0XTQMTyTVeoF+zwrQKV45trCuhf4LQCXjC8Vj9uBewN70
	5CfEKOKx4ioeu6gDGeyzqRNsVIZ5E/RaVHeUcjn75HXKi0NHiJdGnUbfA3M9pBc3Byw==
X-Received: by 2002:a17:906:cc9c:: with SMTP id oq28mr12999775ejb.287.1556030143128;
        Tue, 23 Apr 2019 07:35:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcO1i70mGDImxYF8hwEXTidKxJrdZB3maqkmi97DPLXa4CTFCj7v2+eqQ8Fl8LFBwGFFxH
X-Received: by 2002:a17:906:cc9c:: with SMTP id oq28mr12999742ejb.287.1556030142420;
        Tue, 23 Apr 2019 07:35:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556030142; cv=none;
        d=google.com; s=arc-20160816;
        b=vnvR20hYGnHHVZf8x/C8d0vrFGPCMD51JrzL4uuZAgo42Pgsk/ypZXHPdwJx9lQUJu
         ppJYj5zvWFr87cbE/IU2vYqBH+koSV9Vbdd7xIJHtLpN2hOcRv0Q05Wo8QWN9VMHu2VJ
         MYJP5ocLrFAmWhjGlH1Hh8Eh7TAQ4tHw3vpkk6Vb55HEh86sDWFGodgytWkmuPiqW5Jw
         oXC1ztTDzBy+/GzkkWENRkHeBWmCm3jogIXEr0PEdson2C1i9xeOjgDVneND7gARSLOk
         7zNI6M4/VZeMUxSg8/XYM/XeQP52AMAHEqGG209B57yf96644KXTupJTLzIqRl9Rq8Lx
         5Ddg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=k/G2KUsFtfhv1I5sxjAd5L+a3It5LAnKQGLM+DApu38=;
        b=gEqsffR8S9ZOa6TBfZoT1q97toFUOYY04isZAyyb9csZuDryhPxm0ZEqu0JI1ScDIh
         pdmg7LH6J4OK6pBi3nGioDtfmF77pGkeR+UYO27qfaddMW9+E2jbGZTyBBXbxt21QjEn
         2v6L7fSHI8NnEoRtYn/i2pKuud21MSFFjJZUNIv2+J7IE1e0qO3//dimUUyfSspPWkd3
         8vBC9HDwU+NB2jDDxaTMgM37a0pHK8T8FXy1l+6axQuWUP/iChCRjRl3AL4QsirDm97t
         DD88LcNoI4d/VYRan7DbzYSQdGpAOiSe2JxHASjBGI0l5NxumS74gCgfUGDhdrGYJ2dl
         47uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp19.blacknight.com (outbound-smtp19.blacknight.com. [46.22.139.246])
        by mx.google.com with ESMTPS id gh13si684418ejb.185.2019.04.23.07.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 07:35:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) client-ip=46.22.139.246;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp19.blacknight.com (Postfix) with ESMTPS id 1362E1C19F2
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:35:42 +0100 (IST)
Received: (qmail 9400 invoked from network); 23 Apr 2019 14:35:41 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 23 Apr 2019 14:35:41 -0000
Date: Tue, 23 Apr 2019 15:35:40 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/page_alloc: avoid potential NULL pointer
 dereference
Message-ID: <20190423143540.GQ18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190423120806.3503-1-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 03:08:05PM +0300, Andrey Ryabinin wrote:
> ac.preferred_zoneref->zone passed to alloc_flags_nofragment() can be NULL.
> 'zone' pointer unconditionally derefernced in alloc_flags_nofragment().
> Bail out on NULL zone to avoid potential crash.
> Currently we don't see any crashes only because alloc_flags_nofragment()
> has another bug which allows compiler to optimize away all accesses to
> 'zone'.
> 
> Fixes: 6bb154504f8b ("mm, page_alloc: spread allocations across zones before introducing fragmentation")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

