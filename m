Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6E57C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92B6721841
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92B6721841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 245636B0005; Mon,  5 Aug 2019 05:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5A16B0007; Mon,  5 Aug 2019 05:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E6146B0006; Mon,  5 Aug 2019 05:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8F686B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 05:28:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so53132177pfw.16
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 02:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=jbBH5BCOx1ui48PkJmTitR1c1ij0f56knoHSH9pBEmE=;
        b=Edoz7n4kOmGTinGD+o0PLzozSJ+32Q87Nr79LpLlvl8YMgAEVF7NsXM8qHz8sDBLBf
         oiA58iPOPEa852apByKb8VTgj2jRgEsQEXe6SlS8iQV17dT5K9BWtR8UkH4j1INxCLTI
         6ffv8qj7dzbmK4uCleaYzxBoPLtp4VElSwiwpWsKlEYfkByzBc9OTy1AHllzo41xxLiy
         A1dPqmcUk23ynpxv+atGm7QVHkR6f7VelU8kbKR5mtLx7ufKdTKe9Q40lrK3ml1XUPBz
         oBp7IjdAinA1ya9SJFgmBGbAhbGOCebjyp7KyHgInEVGukUZ7YJA8m50MyUoGLMFT6FC
         yLYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAW7swjBK64MQ7hIXBZqexnSMqJLKAlsB9DiJGCyntkqN0CwNlOi
	FV85vMwina2qurBfdx8B9coZ2F2YB+/pd7eAXmJYf4ILaGtX7hVG3FPMKjuqeE/OjfxmHhWfMCk
	Df/DLfCXpFRyOXcsm8HSAxuL8S/vmQIpaaEpjq00CO5+YIZzv7NkPlIlZ5txa3u+R9w==
X-Received: by 2002:a63:e901:: with SMTP id i1mr118093345pgh.451.1564997286396;
        Mon, 05 Aug 2019 02:28:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCzL6pImL11CEiSuMvz+7lB85+eMARXX7/M5oomjlhJDEUtNoyDYgO1rH+m7o+xCkYyEhC
X-Received: by 2002:a63:e901:: with SMTP id i1mr118093285pgh.451.1564997285314;
        Mon, 05 Aug 2019 02:28:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564997285; cv=none;
        d=google.com; s=arc-20160816;
        b=OLUgMDa08S0tzKQaAimynIkRxOxQjTrBPpYWlFelcWYwyV5WPClfA/QH9fiCHquc4U
         CImxD7wc3Rzu+EDlsqXypmLp1MJ4kPoCIVXvmaAljtaMrXdOM4LVjYTrdsLoYaWeL1JL
         5efy6mqCvBxiJRLyji6JUwQ5CUt+/bYpkr0/O6YU7PD0dW7fxrYQdE4csYP8c01BjyQY
         qxBIooAK6EqYpMR6ZNwuOuUXV4uqMZftXJuwvsYUC9iUkcRrKvcXfez3P/PbE+mUUpwh
         LW7TOxfdzo/yihhjWUcSAgWx5ZRo2YCDJ1dnxsawm2q6ivl3DcuuJu0SlRZbOPcEJFX2
         dnfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=jbBH5BCOx1ui48PkJmTitR1c1ij0f56knoHSH9pBEmE=;
        b=Riuxus/xMvbpUK8395erWiTESZwJoMvAb0gwMadqycXBFywJ3aEhYyBMPTzfAnQPXr
         4RnnEIq1xpQhrfZRBXooCXGYYQPYHDI7s0OMJTS4mqASWQJtXCLWoVJGQEzAaBvHgnAB
         qWQLoMwBfUyzJAJKKVkxlu0p4McPq6O//cJ19YmCQqzSPA2iLI5WYqcNswJSzUjngXSG
         C7FvE2Vkcp7IsKFZ/FAVDtESdiobg3ef4FoWVgV0gq5QRElK7ZfUUocI7w7nUrHCxyXq
         P6kgP1WvxB9ooattgc+BFtYlvn5wAOL0wyOBSv+vNl+h+CFuOqFPBdbbZsN1RuyvIr4m
         lxdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id r185si42224412pgr.506.2019.08.05.02.28.04
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 02:28:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D47F6A100003394; Mon, 5 Aug 2019 17:28:03 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 71319445091026
From: Hillf Danton <hdanton@sina.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm, reclaim: make should_continue_reclaim performdryrun detection
Date: Mon,  5 Aug 2019 17:27:51 +0800
Message-Id: <20190805092751.4976-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [PATCH 1/3] mm, reclaim: make should_continue_reclaim performdryrun detection
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 5 Aug 2019 16:43:04 +0800 Vlastimil Babka wrote:
> 
> On 8/3/19 12:39 AM, Mike Kravetz wrote:
> > From: Hillf Danton <hdanton@sina.com>
> >
> > Address the issue of should_continue_reclaim continuing true too often
> > for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> > This could happen during hugetlb page allocation causing stalls for
> > minutes or hours.
> >
> > We can stop reclaiming pages if compaction reports it can make a progress.
> > A code reshuffle is needed to do that.
> 
> > And it has side-effects, however,
> > with allocation latencies in other cases but that would come at the cost
> > of potential premature reclaim which has consequences of itself.
> 
> Based on Mel's longer explanation, can we clarify the wording here? e.g.:
> 
> There might be side-effect for other high-order allocations that would
> potentially benefit from more reclaim before compaction for them to be
> faster and less likely to stall, but the consequences of
> premature/over-reclaim are considered worse.
> 
> > We can also bail out of reclaiming pages if we know that there are not
> > enough inactive lru pages left to satisfy the costly allocation.
> >
> > We can give up reclaiming pages too if we see dryrun occur, with the
> > certainty of plenty of inactive pages. IOW with dryrun detected, we are
> > sure we have reclaimed as many pages as we could.
> >
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Hillf Danton <hdanton@sina.com>
> > Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> I will send some followup cleanup.
> 
> There should be also Mike's SOB?

Yes, definitely.

Thanks
Hillf

