Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=1.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B965CC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:00:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F0FF2173B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:00:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KEqUYzrw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F0FF2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F7486B0008; Tue,  6 Aug 2019 07:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 282286B000A; Tue,  6 Aug 2019 07:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149B66B000C; Tue,  6 Aug 2019 07:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9D976B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:00:31 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j96so2260964plb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:00:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ey/TDb+j3ulf/Kh0DyGVxExM26fXVHaeQeTsCyT/hWk=;
        b=QLnRG7Yx5quCpay4QqW6J0W5DSHvxFjCCUEqWqNF0ywQ7YmdCDp4rVjbz+AZL1Lwgo
         AK3Lcbbtjjo2JEoyXVOjEZTY7+bst4kJnLvqkJaRsjhten6AfmC4PmEWPiAKpimSnHFE
         BHAIXye0u5SeMMLzNlil+v03wllLeRgGAAHlgV4FockPkh2RPTtI1xhZ24r0/Kp54NGK
         ak92bK8k/NRpxNLB/dyIAF+RSaaSlCdOcFLI3WI/NxQN/tPksHXpQdgHOOjaiB2IU0i1
         4wb2tJbhrTRUMShfcuVeq2kX3ap/kHM82VTOJAZvg44vNT/vSdYzOq44qgjSoyB5GEFj
         z62A==
X-Gm-Message-State: APjAAAWLPZJlcbgXn56pn9o7qlzQVp1WfQgEcKYEuD/gEohxmEHkSi7r
	BZfpseRQS7B/65Oot8S/49dloj+8hZBzdM7wscj/eEY2mc+UyKIub5Z7Com6XzB2RrgWOl5/A6V
	Xb43gNwsWHBZfLRKyPFOwLNAVlw72AwM55+7ufL3eQZxTqMhXrekT+womH9PfwVk=
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr2530827plb.114.1565089231562;
        Tue, 06 Aug 2019 04:00:31 -0700 (PDT)
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr2530771plb.114.1565089230858;
        Tue, 06 Aug 2019 04:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089230; cv=none;
        d=google.com; s=arc-20160816;
        b=DfRrotuk3Ngrh5STsoP79h1YLp3oc73a0hO6Et7F4SjTkhreBP3sGubucXjFTjuZtr
         QBVnn/vHOaBvLFJdyL3PIw0xtZtosYMhBdAvpEqAZLL0LAwhzDJlloG9yWhIB4XGjzfD
         sgnFsfrWeHYPDwlG2OhhGPrauGBnAvYLT+gPzqmIItF77vY7Pbu6/JTDjxIQEfpwhRUO
         jVbkKzKwYcXi689MM4GVHE0Xhn436QNTnVcOlET4pPASBU4hvHfmBpU4JPflziuZGh6d
         gJhxQMbvZuZ2AQY/m67d3pRTpWd4AhS2vD46uUZlifWtMGB6/Ih4TbmTJQ2UeFQES8lb
         6diA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Ey/TDb+j3ulf/Kh0DyGVxExM26fXVHaeQeTsCyT/hWk=;
        b=HdmBNzzp59+LNm595QgGNrHO9SHvsmFo4PYEXqc+8XVr5GDiTwYPIZTxiSmtnMnI6q
         AWY3MTvyH0phV2LaYKAjnsChJ6WsATYBwG7GQJO5MQfr7FIIvig4fAshoEuBH0ljhSz4
         SXQioXxt8SRFkOgJ9GcvzTM9lKkZZ3xpJKZJ8RMERbsKifINFXEMiSHiTaYA176/SFS/
         uk1QQgUl6F8JgnLaCycK+tKamgoNvagHH+SQO5ZvUMzsO4LSe4fuZKvmsj3zqwrpJ34P
         LjCDlZtLrDHX+wJDx1BQAj6+yuatamZD2enxka8cRCvWP0aPY0iAw3Ga2DKjPaIAZgw0
         wPgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KEqUYzrw;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor24452599pjr.9.2019.08.06.04.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KEqUYzrw;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ey/TDb+j3ulf/Kh0DyGVxExM26fXVHaeQeTsCyT/hWk=;
        b=KEqUYzrwilv1Xix2/euOGauUH6pBzvZDAJ4XqIXBsBhfjllP1rTaC1iedXkybgFWVI
         NuMwON0aP//RoKcdjSA3dRQrQKNvYN/1Y2MYcf940QORKaAvbupp2Dx6yWU5xmTL4Th5
         vlOw7wW8DQtzPv1skB7m53NKoknnmnnaScTAb2DBaq3uglPOGK3lJFdmoFgPzMybnbMq
         TTvdH3aS0wrGOwWIPqGP1qwP9Qz31APO31T9pIgCWihZj5ZZ24R14KIZdixbp3KuerIR
         SZrwo0GgH7W1mjrvAYXO7Ry7+OPPirPAZpeoopuq+ieLHQIjfaH0uej/b0BprddCl/LC
         topg==
X-Google-Smtp-Source: APXvYqwA3k4rZRoc3mC70Gp392chl8mhMwWXeW4M2H/sluIt/TX1w6gunuu5hlyUCqDil/zBoqvVGg==
X-Received: by 2002:a17:90a:bb8b:: with SMTP id v11mr2575447pjr.64.1565089230260;
        Tue, 06 Aug 2019 04:00:30 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id p1sm92628404pff.74.2019.08.06.04.00.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 04:00:29 -0700 (PDT)
Date: Tue, 6 Aug 2019 20:00:24 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kernel test robot <oliver.sang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>, lkp@01.org
Subject: Re: [mm]  755d6edc1a:  will-it-scale.per_process_ops -4.1% regression
Message-ID: <20190806110024.GA32615@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190806070547.GA10123@xsang-OptiPlex-9020>
 <20190806080415.GG11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806080415.GG11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 10:04:15AM +0200, Michal Hocko wrote:
> On Tue 06-08-19 15:05:47, kernel test robot wrote:
> > Greeting,
> > 
> > FYI, we noticed a -4.1% regression of will-it-scale.per_process_ops due to commit:
> 
> I have to confess I cannot make much sense from numbers because they
> seem to be too volatile and the main contributor doesn't stand up for
> me. Anyway, regressions on microbenchmarks like this are not all that
> surprising when a locking is slightly changed and the critical section
> made shorter. I have seen that in the past already.

I guess if it's multi process workload. The patch will give more chance
to be scheduled out so TLB miss ratio would be bigger than old.
I see it's natural trade-off for latency vs. performance so only thing
I could think is just increase threshold from 32 to 64 or 128?

> 
> That being said I would still love to get to bottom of this bug rather
> than play with the lock duration by a magic. In other words
> http://lkml.kernel.org/r/20190730125751.GS9330@dhcp22.suse.cz

Yes, if we could remove mark_page_accessed there, it would be best.
I added a commen in the thread.

