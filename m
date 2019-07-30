Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77090C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D055208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bYOaA1bj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D055208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9F9A8E0005; Tue, 30 Jul 2019 08:11:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F638E0001; Tue, 30 Jul 2019 08:11:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93E9A8E0005; Tue, 30 Jul 2019 08:11:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D94D8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:11:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y66so40688057pfb.21
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:11:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Wpon5LXiMRjWM4VYIexd4NaoumE7zgOXY2Q2zhMR31E=;
        b=ZHeYehRw8PZ26E37KvL7mOrbodP1dLxf47K7WGDi6g+UBXbR3pLmxW3KXgyXcatFn8
         ikKCXB1FgeXVuWsbOeLSM1VRBwo5e5Ez6MS95gW3av9CaGPFwqKMpC9PdVziaI44OliG
         VgS/AOLNk1Y09RMUbEgOcThRgzQJqqMiIxTtd13OiKKdLM0q+pxJunF0sIeb3FH+l0WB
         FZsJx++h/xHld4FrXY7XSShm5bEiMn9eQDmvG4IlFPF8a9oZ3PRnMVaNMVe7iqcHxOMu
         74dEujV4ZeE59AMA1gcJ+tzXeRSSpwdTBP3fL8/rXnOa9VjLPnd72mrqfZq3IPWEVeUw
         cwYw==
X-Gm-Message-State: APjAAAVXoxelw2OjMI2JEZUj5YyuUfFq1zmivRMDkKR/+V/3f2nTwNKz
	1RoTlVPePIGjD+6FpCSq/2VJsE7dhWdVvdp/AfWe9aJcJIotP7cpggv+b3ddTg9XLjHCozs4W13
	m1g1uDpLA16E1ylrNqGUECtwe3OlKFsAWZ8MVqhWohyE2Jdbc9LYdUUrarnwwe/4=
X-Received: by 2002:a65:6547:: with SMTP id a7mr87631133pgw.65.1564488677754;
        Tue, 30 Jul 2019 05:11:17 -0700 (PDT)
X-Received: by 2002:a65:6547:: with SMTP id a7mr87631067pgw.65.1564488676748;
        Tue, 30 Jul 2019 05:11:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564488676; cv=none;
        d=google.com; s=arc-20160816;
        b=upiMEfknFnFpjz6nuLwLqJoGkmVr7xInfxR4C2bvMQaceV1OMO2nUG3ixzRmk/CjIJ
         doxk6oBx/oW6as5O5tCsVERTZly4RmDL+QxesXPDAFI6opPKuL2pwJFeGV0WW59LuxJc
         fjBMhw5mVHcJSH7CUcyqPJWGoc8+CXyCBC1v2GA3G5XI3CdPO9nwh6mZ0cukmPF8ffgP
         +3jFnYAA0FlkgcjTgfbF78Q74X9NfVCfht9Z8gT1BOiA7+qjSl4fEUsY94DjdaVyXRST
         NmuR7ZA+brzYHMixsOQG5tjVvnGrt7x81CzGJIohnVSDodenszmZK5O6lhE4AMQtZwCC
         nbAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Wpon5LXiMRjWM4VYIexd4NaoumE7zgOXY2Q2zhMR31E=;
        b=fH0zshKXnkf7VdiP0U26SnqnzSyy2ZTTIsHiAIfo9OMn11I1BA0kNmkh/B8lArhMiM
         NoPflgGF5Vs5iD0Z7Czb7wi6T6F2Y19unLjnlcDAap8OiYxS+6HA8l8x9kIo9+S/yaTX
         mEKEM0loBgwkb2HemzsqAcqTOFlXp6mVgAYIvZQtMgKI4DqbPaIKm48NiqmgT2R0V2dd
         6c+nm34Y7VL0SaqsAUZYcHbAqEF/9hfGFjjebRygZ1G5G+3J1DaZ89EFpTjS5BLFR/px
         pubOwmvkgdKWe7KX205eR4O4R/gtoSzK7hiPV3BvUVwa5iDWpYaSLJU/TLntr64SsZ1U
         ujpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bYOaA1bj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o39sor77281883pjb.10.2019.07.30.05.11.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 05:11:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bYOaA1bj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Wpon5LXiMRjWM4VYIexd4NaoumE7zgOXY2Q2zhMR31E=;
        b=bYOaA1bjRco0KHiZUAi1zM5jzjhzBM9TFIVJFCNiCUd9klzlUnSBKKxdDG4ISThyEg
         dKAvL9lhA4uGT5YSTc3c/AQ7R68uUd7Qh3u1Ib/j9CIUG36TpMQxJJbYXw7vHVZcO59A
         BczKwzrUBb0l+kBbfjr/G3/FnLYjZdWYP52hSIax7z7O3Giv8C50XnV4a1Vpu+gJS4Xd
         8PI7hObtiD+MWvhhPxwZw+For/ajH7QgYSyEkQtIVLp2461/mPALNlafvpkaB1gsbWiP
         /RDkpdDEAStH+4711XBFhYWtRgR3XN777zbvF4LMwCWK3qOQ3nCovPrhKed6mVA5NYFU
         K3cA==
X-Google-Smtp-Source: APXvYqz+7hvZ1/fI1zRquioobNABSKavQ8310Y3CJ+5E/soZhgZLg7s+89NlIGB9IMVG6KNx+Kd2Nw==
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr114501776pje.123.1564488676117;
        Tue, 30 Jul 2019 05:11:16 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a5sm56153980pjv.21.2019.07.30.05.11.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 05:11:14 -0700 (PDT)
Date: Tue, 30 Jul 2019 21:11:10 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190730121110.GA184615@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729083515.GD9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:35:15AM +0200, Michal Hocko wrote:
> On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> > On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > > takes above 6ms with preemption disabled easily. When I see that, the
> > > > reason is it holds page table spinlock during entire 512 page operation
> > > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > > run in the time because it could make frame drop or glitch audio problem.
> > > 
> > > Where is the time spent during the tear down? 512 pages doesn't sound
> > > like a lot to tear down. Is it the TLB flushing?
> > 
> > Miguel confirmed there is no such big latency without mark_page_accessed
> > in zap_pte_range so I guess it's the contention of LRU lock as well as
> > heavy activate_page overhead which is not trivial, either.
> 
> Please give us more details ideally with some numbers.

I had a time to benchmark it via adding some trace_printk hooks between
pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
device is 2018 premium mobile device.

I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
task runs on little core even though it doesn't have any IPI and LRU
lock contention. It's already too heavy.

If I remove activate_page, 35-40% overhead of zap_pte_range is gone
so most of overhead(about 0.7ms) comes from activate_page via
mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
accumulate up to several ms.

