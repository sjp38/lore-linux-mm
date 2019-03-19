Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91FC8C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:56:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E44220651
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:56:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E44220651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F04D06B0007; Tue, 19 Mar 2019 13:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB34C6B0008; Tue, 19 Mar 2019 13:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA2D26B000A; Tue, 19 Mar 2019 13:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 946996B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:56:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j10so23577540pfn.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kmxyYlZJqPyamFHRGr02XpQzqXeTOd4bJ0ZuHzeOYSQ=;
        b=XwwI0Jl6YHnuUwmq5iw9ZhXps7u4Fs2zgqWNIHgRHCtG7t8A/vqkAFMyg3QIfvSZt3
         4e1ziRlff22HVrA/MmtfykmF+H/jiGVUOAYHKmONKM7A6nOvnuE/nNqIpIUlqUVy3Pk4
         QC+p4bUNxmFxz+daUndwGLECwgb13hQuMzVIW9aUm3C08raXzFE73ZOES9K5oXzLCF7g
         HPzQ3/IVRcHg8H9MQ3Ry64JqJCRegQnd3gMH5LF8QSgbgXhgc5DWKBAbgo5LvHqiBl/F
         d/NxlgKUbWUffIm+8ZjmmvjUiJwdkZ8XHmfA8ESemLE2sKH9LspqCtyOu0l2fzsP43bQ
         ko7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUiIeDTrs2wFHz+Z8mDuNSc7E2QP9vEUCguxiVH77UK7rxJZAq4
	yiJaSBn7YCRJXCLqepNaqnENKH+C8/t37ap0VhySSv5PAU/e93Yi/I+D/QjnwGK4eZOmdmg7hgY
	Tdo/48zwMHoCEAEBSz88Xo49U5cpbKU82DfW0+tUBr1bCh/8IXBE48ZVo6EwfKoQgpg==
X-Received: by 2002:a62:1e06:: with SMTP id e6mr25861664pfe.168.1553018201229;
        Tue, 19 Mar 2019 10:56:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYhRbxn3YV6DjFEQrQDeuEaNA/iwrqxkVfwMW5lbyp8poEVYsUxdbMeVzVN1bQ7Z4hkCE9
X-Received: by 2002:a62:1e06:: with SMTP id e6mr25861607pfe.168.1553018200175;
        Tue, 19 Mar 2019 10:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553018200; cv=none;
        d=google.com; s=arc-20160816;
        b=B3MtYlO9SYkirsYZ797aJ+kJfI8alfmcernyuH/9Q8potqRlgD/CgjziU2xsfB1ahI
         qFtJsKaJkXi2PJXG7I8iql5weULW1oUCVVAn+8DQtxTao5IxTQoP2/qDBTmFj6Um981J
         9C9bWpGYeQ0EWr2GQ1mL9DWGIDJtvlTDKFlFsl0mdkROyELsfGSCksgK4n9VF3p4svxM
         /am7XFuKr6Nh0ZgOXZeLFXwFVFZa64rbJ0ZtVUcnrH1XYZlXS2/YKSsftTpXASbOwdIo
         f7VrxTitiQk+YzSA3CoOF13o6hG1wRgFCWsjf0rqOTKwSXcbQ1jEjbPMdkGviDbFtBZ+
         X9gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kmxyYlZJqPyamFHRGr02XpQzqXeTOd4bJ0ZuHzeOYSQ=;
        b=QiydxmKQyoLrjU7ip8YZ8+LHdcN9fN22Fcus9lwfn5ZCI1jkTA2Yh1kfw+5ylnf1TX
         Mvpgo/vnuazJvhPwyhZ9hbbcKcRsrwKrgFj/IcfvYg+yeNdaGL+5L4PtfrT9poA0X/vH
         +BDqxkxcrwx4+27ITeBmUufyYgqiEJUFdX1v/PrRc4hYPGqKW3apcBJMhAu5QKE1QVBN
         SWqUeAIRhRFgqArP09kHmyADauuzsAQCOs7iTJ3Bfrhj9Y8SNdyWvbjD6nJkabwd78go
         8ZZl2wt8aq1Mjfx5pMpKhZFyT+uB2/WpKMVzvPa/iOXH58ji5S6v9r0C6iLUWhADBtt9
         MSbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l187si12448110pfc.43.2019.03.19.10.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C383B3A59;
	Tue, 19 Mar 2019 17:56:38 +0000 (UTC)
Date: Tue, 19 Mar 2019 10:56:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.com>, Mel
 Gorman <mgorman@techsingularity.net>, Levin Alexander
 <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List
 <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org,
 lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu
 <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz
 Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>,
 hch@infradead.org, Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang
 <hsinyi@chromium.org>, stable@vger.kernel.org, Joerg Roedel
 <joro@8bytes.org>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for
 page tables
Message-Id: <20190319105637.4949b00b854e955d61c0359d@linux-foundation.org>
In-Reply-To: <CANMq1KBKF9aRj+8t+AQusNLOF5jrHJ4qY5C00AKXkO6e-8wKuQ@mail.gmail.com>
References: <20181210011504.122604-1-drinkcat@chromium.org>
	<CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
	<20190111102155.in5rctq5krs4ewfi@8bytes.org>
	<CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
	<789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz>
	<CANMq1KCfhWdWtXP_PRd_LEEcWV8SQg=hOy4V7_grqtL873uUCg@mail.gmail.com>
	<CANMq1KBKF9aRj+8t+AQusNLOF5jrHJ4qY5C00AKXkO6e-8wKuQ@mail.gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019 15:41:43 +0800 Nicolas Boichat <drinkcat@chromium.org> wrote:

> On Mon, Feb 25, 2019 at 8:23 AM Nicolas Boichat <drinkcat@chromium.org> wrote:
> >
> > On Thu, Feb 14, 2019 at 1:12 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> > >
> > > On 1/22/19 11:51 PM, Nicolas Boichat wrote:
> > > > Hi Andrew,
> > > >
> > > > On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
> > > >>
> > > >> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> > > >> > Does anyone have any further comment on this series? If not, which
> > > >> > maintainer is going to pick this up? I assume Andrew Morton?
> > > >>
> > > >> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> > > >> this should go through mm.
> > > >
> > > > Gentle ping on this series, it seems like it's better if it goes
> > > > through your tree.
> > > >
> > > > Series still applies cleanly on linux-next, but I'm happy to resend if
> > > > that helps.
> > >
> > > Ping, Andrew?
> >
> > Another gentle ping, I still don't see these patches in mmot[ms]. Thanks.
> 
> Andrew: AFAICT this still applies cleanly on linux-next/master, so I
> don't plan to resend... is there any other issues with this series?
> 
> This is a regression, so it'd be nice to have it fixed in mainline, eventually.

Sorry, seeing "iommu" and "arm" made these escape my gimlet eye.

I'm only seeing acks on [1/3].  What's the review status of [2/3] and [3/3]?

