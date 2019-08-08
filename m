Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 610CEC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:31:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DE80217F5
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:31:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DE80217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18206B0006; Wed,  7 Aug 2019 20:31:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7866B0007; Wed,  7 Aug 2019 20:31:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADD9C6B0008; Wed,  7 Aug 2019 20:31:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEA96B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 20:31:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so54420601pld.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 17:31:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qrNjVF/GRBgfZq6OnkNxeIeqsvMcJU6Bq/cYCGhtReU=;
        b=oud+iwMBZC57KW/xAjXDigkgBVUdgu1LWgx47ch30wz+1IlHy5omXodZtpp9cR6La1
         ix3+CxWsM97grRya9TlsHQpTaMQQMMdNmNNlxEngeGpmBio1bI/daTEQbLSy0f+7Pq+c
         bn90+YcPTJzzrcQTAFBRqB7OxT/h4TCLWh3iYf7BaMI5vhJZpFTchqbD775okChjPSZb
         glNDDA8X/+zAaWHWddNbelzSbBVrbf+BsE6iGXyCFLcWK9CKB1CXDcx/ZqzgwiAbaKkV
         ajuhGYy9Ey/T1pmGIVj/B9WozQ7HPA04iMbiGqJCjLgycj+1SdG75dJ7U734p6lUvtKW
         Dj2g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXBh5p/17RrNi/yu/Ep+ay01mJaowogQxTImIjkcNXCf92OSc7I
	luvvU6g7amDO0g8jVb6dVFt8H7YwFOzuAY25uCprlfEPOBHMiP52iI/8RPIbS8mKKqStcvjVGsk
	VdTeWYTJQNZuySDiE/jAuZm/aT/6NbfrxJ9iyk2LHGxsdo/slkMn8lIGv3OmIdpA=
X-Received: by 2002:a17:90a:20a2:: with SMTP id f31mr1108770pjg.90.1565224294186;
        Wed, 07 Aug 2019 17:31:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLrMrirD3SRoHQw/n8r1ZVq1XBfDOiTtSQhFwMtm1XxhS2ZvpuKZDka1U6p9bVHlW3oRny
X-Received: by 2002:a17:90a:20a2:: with SMTP id f31mr1108724pjg.90.1565224293491;
        Wed, 07 Aug 2019 17:31:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565224293; cv=none;
        d=google.com; s=arc-20160816;
        b=AK1dry/wEvZDBJJYqEjcSx5B7OyZvixmqRicryM1mgU4p/cQEpFBS1oMXj7mAQrBKh
         zOOKL4rTJ5edVNoUk8SUXZuTBtn5LXnoDOZytj7cPJdTdhyELyPIB6yTa+V0pEfRn/no
         mHr7Zyn63dIpFRS3TO9QMnOSY//HvspqhNju/y1eFtLQp7G+0csDlBDX9vE93PY+eVVA
         nsXKAT4Js3L9DPg7Oj1KNu76ebey59DpQyfsg1lFywTkYgxNWo4Sr9BE/EN6vjwrOpBc
         bT25/+NP+JUnTJ+qqAGERMsWKoF/18uNFaPmUW8IvXzktyNH5TtogwArUt/QQbqL/suq
         7OFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qrNjVF/GRBgfZq6OnkNxeIeqsvMcJU6Bq/cYCGhtReU=;
        b=HmD/sOQeYmxKtsC3kP/tTGCM546ZOQjXkJalUkiKyweXC42fNS41bB15WSrj2E7Zr6
         lSqumm7sYenwfe6I+0SFG5fjNLtRS1ssWOneR6fgiai/i80nCsCjXDz877mBx5gFv3CW
         IkDzi0lbFxui7Cd4QaPnVcpBwfSnFAFAvQ7Z9CDCpayQYqt05OLaC/QDsXLmE3JuES44
         HCBJbhNUBmTNlnWQXTa9LxFKPoHBA5Yx/5k/6Pgyu9TXrowM0CffGVoMIQ4NZNG2946L
         2ocRYJzHoQtT3DKazKzHdvCEuCe5/vURhiKbqnn224jfgtizrNuWeyp33MkJe/Ww68tw
         SO6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id d22si43949871pls.112.2019.08.07.17.31.33
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 17:31:33 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 0D0FA43D7FF;
	Thu,  8 Aug 2019 10:31:32 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvWK1-0006q9-3L; Thu, 08 Aug 2019 10:30:25 +1000
Date: Thu, 8 Aug 2019 10:30:25 +1000
From: Dave Chinner <david@fromorbit.com>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190808003025.GU7777@dread.disaster.area>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
 <20190807220817.GN7777@dread.disaster.area>
 <20190807235534.GK2739@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807235534.GK2739@techsingularity.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=InmijoeHuMX5d2-jVp4A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 12:55:34AM +0100, Mel Gorman wrote:
> On Thu, Aug 08, 2019 at 08:08:17AM +1000, Dave Chinner wrote:
> > On Wed, Aug 07, 2019 at 04:03:16PM +0100, Mel Gorman wrote:
> > > On Wed, Aug 07, 2019 at 11:30:56AM +0200, Michal Hocko wrote:
> > > The boosting was not intended to target THP specifically -- it was meant
> > > to help recover early from any fragmentation-related event for any user
> > > that might need it. Hence, it's not tied to THP but even with THP
> > > disabled, the boosting will still take effect.
> > > 
> > > One band-aid would be to disable watermark boosting entirely when THP is
> > > disabled but that feels wrong. However, I would be interested in hearing
> > > if sysctl vm.watermark_boost_factor=0 has the same effect as your patch.
> > 
> > <runs test>
> > 
> > Ok, it still runs it out of page cache, but it doesn't drive page
> > cache reclaim as hard once there's none left. The IO patterns are
> > less peaky, context switch rates are increased from ~3k/s to 15k/s
> > but remain pretty steady.
> > 
> > Test ran 5s faster and  file rate improved by ~2%. So it's better
> > once the page cache is largerly fully reclaimed, but it doesn't
> > prevent the page cache from being reclaimed instead of inodes....
> > 
> 
> Ok. Ideally you would also confirm the patch itself works as you want.
> It *should* but an actual confirmation would be nice.

Yup, I'll get to that later today.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

