Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A55E4C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 05:45:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 217612087C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 05:45:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 217612087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 828706B0003; Sat,  3 Aug 2019 01:45:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D9796B0005; Sat,  3 Aug 2019 01:45:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F06C6B0006; Sat,  3 Aug 2019 01:45:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0FD6B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 01:45:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so49644266pfe.1
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 22:45:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=GRc55awTk9gy3eO2deUSrwkeOmp5WLzvk+P8I5kVxL8=;
        b=Ej2wRtUK+mgxIKXrxCeyA+FnemniTZVoBluDUUObdP5Rxb5eJV+6lKiW/LupwsHcfc
         iT31z0e5F0FNz0asP7cpJq5iclKLbJmloD2XKZfbapON24cP0T4P9+wgwu22iaZkjm8D
         8b8V5ZwZUXG4ZebAgk9Rb+QX1WeSHzWVxoDZrdo9UhZsU6r4yaHxFB6oxyQqxHJPoGWM
         EfBLMIklwM3cIMdYG0ZjCsPrqJW9owPdo31hdomVmx5ASFkWj1qW8rqkDcr2bTSdfn9o
         aKKZoibcAt9Mnj25pneCP/qGyoqVPQ5CDcftEMlymdjNNTYUQ+CXJAVltkWJ3lilZsXH
         vW/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXR4stM3jmnWup2B0K9/R9QNpeAJ+q18LkeO69t6zNxDcfRJL2N
	dX8ZmBQAUcJNepam0dRVLlYp+o9sIMQ3eBRtL76SqzarPlolCK88uK1U8agajU445Oyx6G4baE+
	GJiuia55yVqpLYMsjLNTXDKg3rlvjELXGfJyHcspStA75yErlwoNX9CRyLiTTja1Fhg==
X-Received: by 2002:a17:902:925:: with SMTP id 34mr133740035plm.334.1564811140815;
        Fri, 02 Aug 2019 22:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXSm5dSGnb0Jv8/RJtUPsDoP+keA8ERVsT+o/05jLvhuiGxL2854o6Z20p4Li8q8fFoSSP
X-Received: by 2002:a17:902:925:: with SMTP id 34mr133740002plm.334.1564811139960;
        Fri, 02 Aug 2019 22:45:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564811139; cv=none;
        d=google.com; s=arc-20160816;
        b=V5zndswgqH/drXRkD+/53Ebb49GM/cXNUR68/KXPrXvoVB++vcRpj9asCDUTIyaAoP
         QodKoKpS0kuuus3AOuKa7PXlX4MBws/OY3QPvLFF10gjsFP1HNCAY/IACYVAHBMASJ1B
         XFCx3AV9BTwZLhdF38nFANOuAjmU4BHX+9vRu5oEapT/2P2mLBk+lhliBuiXYNfBjz7e
         eoaDikbPQhmU01Meby0pRehRw7QI1KdelPw8h202gnDuDrF23azr/hnZ7BGlIC0I8uGr
         mDSmOH7WZ+5Sz3y+2Yc+uqwqDQDyvA49ejdAv+EmpZuRCtUoHfpwr/zexYNqtSEsM+jq
         JqqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=GRc55awTk9gy3eO2deUSrwkeOmp5WLzvk+P8I5kVxL8=;
        b=mU2L3Fmau9DxOAwMtxMke7LR/fSUV4Ryp87JmTm+nN5x8PREOMTsCsZ1Yh9QRQQHAQ
         ctFrocLIn0h35VEEERtq/scaOMopuWXo0NNV8o4FHdZIH+8DrcLANL8hpOoXs28wGTJ4
         x/l+v1HUOYOWqc1cdkLuQV/50HzQRo3+dnPJwV3kV5Lg7AQpXl86YIvPE4f34kDAmAcT
         sHnW6AZplQqmJbCbuiz5CIube5g3PcfsMe6JdTYFE1w4t2e3jFmExvSEWLRyud98pOgz
         vpsFIAF1yxMVgVpdtptUTx0S7GqHtvzMOIfHgYvNuzB7xBnVLJoy8fWHaYFLGTfLVyWO
         H32g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn. [202.108.3.167])
        by mx.google.com with SMTP id c8si8263107pje.30.2019.08.02.22.45.38
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 22:45:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) client-ip=202.108.3.167;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D451F7F00000AF5; Sat, 3 Aug 2019 13:45:37 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 81730345089322
From: Hillf Danton <hdanton@sina.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Masoud Sharbiani <msharbiani@apple.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Date: Sat,  3 Aug 2019 13:45:25 +0800
Message-Id: <20190803054525.8284-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 2 Aug 2019 21:40:29 +0800 Michal Hocko wrote:
> 
> On Fri 02-08-19 20:10:58, Hillf Danton wrote:
> >
> > On Fri, 2 Aug 2019 16:18:40 +0800 Michal Hocko wrote:
> [...]
> > > Huh, what? You are effectively saying that we should fail the charge
> > > when the requested nr_pages would fit in. This doesn't make much sense
> > > to me. What are you trying to achive here?
> >
> > The report looks like the result of a tight loop.
> > I want to break it and make the end result of do_page_fault unsuccessful
> > if nr_retries rounds of page reclaiming fail to get work done. What made
> > me a bit over stretched is how to determine if the chargee is a memhog
> > in memcg's vocabulary.
> > What I prefer here is that do_page_fault succeeds, even if the chargee
> > exhausts its memory quota/budget granted, as long as more than nr_pages
> > can be reclaimed _within_ nr_retries rounds. IOW the deadline for memhog
> > is nr_retries, and no more.
> 
> No, this really doesn't really make sense because it leads to pre-mature
> charge failures. The charge path is funadamentally not different from
> the page allocator path. We do try to reclaim and retry the allocation.
> We keep retrying for ever for non-costly order requests in both cases
> (modulo some corner cases like oom victims etc.).

You are right. It is hard to produce a cure for all corner cases.
We can handle them one by one to reduce the chance that a cpuhog
comes under memory pressure.

Hillf

