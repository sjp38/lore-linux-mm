Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3543DC282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EADDB2087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:11:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="azkJLUZ8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EADDB2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EDCE8E000F; Wed, 30 Jan 2019 14:11:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9746B8E0001; Wed, 30 Jan 2019 14:11:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8153B8E000F; Wed, 30 Jan 2019 14:11:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8CE8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:11:57 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so340468ywc.6
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:11:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=M4j223sTiX4eMGkNGmN1WWkhqrWqcQOSV+aX1N0vGfU=;
        b=niMMR2TKP1Jteef/oynz+EB9OUbCheb+M+M7KagF9skNInUjUm/E0Q23Destq3sR/t
         QcVd+PRi0Qg4S65vNydB886db+KRs9HBxfmJLS2X/FNZ0NVDZ8uE4bddPCMGhz0Skv5W
         9SMn8KRYDiEzRWSott9L+2soMeHIk8PXSymBmTSwDN02JY3qzSWZypjxrqWMOriNLGsH
         vm/fWSUllM/mzC9/KON8mOYcmYXmvjOeWIjuFeSbC3m/v11qOhI6Gp63PYy7BVRzafHY
         0+s8+OV6Au/Zl8GAn5dofVl8Iwsif/VDBZ5TqKtdJbkg90pklSjoO2FwAh+tKbFo1/Rg
         OqtA==
X-Gm-Message-State: AHQUAuY7wQqazzn6IgyGbKqpMAystxUKX9Me00/LjvyGMf5X3BkNLPS3
	2a+Z2PQPX2lS2pflnFJoq97B8yoMInlAC5/ky/F+E9lmG+wAbo10JB4hkJHs8guEsVU0RukxGq0
	ZvMiGL8ATUA69o5ZPI5RoqS+dX/hfqZWVM1VS0FTA5PQtr9Nk8gsa4v/Fe2OosXm5g1huonB/d1
	Y5QGJz+Xb8k7tjXcAg8ifEt2f8rHv3f/W32hy0hG7qN4zrhHUgnDHqAnomoiaLqkQNHl4PcmwcJ
	NLn7jOHBx/TmQ0xqiokS3r1ZrP9jCg4T9geG62nx635rsE4js1+aNaxdaiys50QT68d138k+D2p
	ocCic12iWCqxuAVEk/RUhxg3EnKig16dhrdW4Dvanp+3VrHierXu2A7DgVQdsFzAYVcfwyZI14s
	M
X-Received: by 2002:a25:6d06:: with SMTP id i6mr10676528ybc.333.1548875516977;
        Wed, 30 Jan 2019 11:11:56 -0800 (PST)
X-Received: by 2002:a25:6d06:: with SMTP id i6mr10676491ybc.333.1548875516431;
        Wed, 30 Jan 2019 11:11:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548875516; cv=none;
        d=google.com; s=arc-20160816;
        b=E9W0ZDW+CmQ2vA0zx/ZlzeiMWJl09Qq3aOwrQuLjGVSVJbPHM0BtSd4585nfN+bnr2
         lbZIBVd4BJygf2JcduqMclz/nXKe/Fir9a9WBpIZJtzMeirUn0P6h5mohApSVE+RbRIB
         A3LRO6yEXavwrVG+jiFFhM4QYmm32g7YuMmUCVGvqZFiK+V6AG3VSJ+NZrBeTkSf2ai8
         JiqYhC6kDJ3uQ0zvKs3y1oCNzCw4fc/TqqlcAhcYFq59E5pO/OF3C3Sr3PH8JrqxA2YP
         GoaKcv3RvjhqAdk/2nGs/25p23cFJDzIr0H5g3NyuO1bZAdU80wPX6cUE+XyxrUDiJ7o
         J0Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=M4j223sTiX4eMGkNGmN1WWkhqrWqcQOSV+aX1N0vGfU=;
        b=UivT2L3iekGtUy6lIzfivPSVV+uo66adp7OIwamKhg0Zyokop2wvlqG+bNPHQK7xK1
         mfYtQHqXaXnYWPSpNyuMWIp+0YTB347ty9gxAzrxoRty3xhI7DreHQLE887roCml3Ax1
         1xxg68BiO8Dh8D4FAZBU6mzIuL4n5oiwwf2k1Isw4V2bDKC4LXwWntBgHRjTf04xriVu
         YmQaRUSGmSSYgtp/qJVananSrNp+btSkmjChLzylwiQQB6uKTgy/gx4VxUhKA6mYsAGD
         vLn0ZC4p9Qm1p8xfslIQKOOnfLNkFYBi8KmzVNEQTMpGMWc9dB9PtZyGrb9JFXRCHh4b
         /E9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=azkJLUZ8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195sor989949ybc.96.2019.01.30.11.11.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:11:56 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=azkJLUZ8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M4j223sTiX4eMGkNGmN1WWkhqrWqcQOSV+aX1N0vGfU=;
        b=azkJLUZ8/StL/5E53v70C5unuQk4f6Ciqs5ZgN9hYqf0WgprVCpGmJfw35DSNFFigH
         JVmOK/jHtzt8P/JqqIEwed/TX1ZFf0ud6XffSASmHI6C8ghY79KgnZYb6Isd5RNkClua
         FQaIW69ilbPoeutkgd0gm95mrYy1COvWQrd88dpMGnxQ/PkebF5X5yUvjgS2yoSNBlUN
         OM0upjn5ctZEGvNWDVcPkYrC2dDtFHVzqK69UsO8y+FvOF106czYSuDNEtf1vGESZlVM
         koBSwBSPYR2tcLjlCvJxtcRP7SRjAYCkyAf0Ruy8coYoG1kClerdGq0mQntTghNaeEoZ
         /Hsg==
X-Google-Smtp-Source: ALg8bN7h5YVXFcOyF0zDnaKnKlQI+SKdghtxY8KdSlfgBjAb4L5Eo4ra6uGIeVkTzTMf2C553vztFJkeE8sMkZo4rY0=
X-Received: by 2002:a25:6f8b:: with SMTP id k133mr29606576ybc.496.1548875515746;
 Wed, 30 Jan 2019 11:11:55 -0800 (PST)
MIME-Version: 1.0
References: <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz> <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz> <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz> <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz> <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz> <20190130170658.GY50184@devbig004.ftw2.facebook.com>
In-Reply-To: <20190130170658.GY50184@devbig004.ftw2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 30 Jan 2019 11:11:44 -0800
Message-ID: <CALvZod5ma62fRKqrAhMcuNT3GYT3FpRX+DCmeVr2nDg1u=9T8w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000091, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On Wed, Jan 30, 2019 at 9:07 AM Tejun Heo <tj@kernel.org> wrote:
>
> Hello, Michal.
>
> On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > > Yeah, cgroup.events and .stat files as some of the local stats would
> > > be useful too, so if we don't flip memory.events we'll end up with sth
> > > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > > which is gonna be hilarious.
> >
> > Why cannot we simply have memory.events_tree and be done with it? Sure
> > the file names are not goin to be consistent which is a minus but that
> > ship has already sailed some time ago.
>
> Because the overall cost of shitty interface will be way higher in the
> longer term.  cgroup2 interface is far from perfect but is way better
> than cgroup1 especially for the memory controller.  Why do you think
> that is?
>

I thought you are fine with the separate interface for the hierarchical events.

https://lkml.kernel.org/r/20190128161201.GS50184@devbig004.ftw2.facebook.com

Is that not the case?

Shakeel

