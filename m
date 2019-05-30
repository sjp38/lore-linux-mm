Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2842C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:58:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D08724408
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:58:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D08724408
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7C76B0010; Wed, 29 May 2019 21:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358996B026D; Wed, 29 May 2019 21:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2495A6B026E; Wed, 29 May 2019 21:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDC796B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 21:58:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d125so3405669pfd.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 18:58:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=XXsLOZQadxBhSzd1txFxmx/ksVLxTCP4p3VJFs76yBk=;
        b=riEt5Tg1Fs121SHDoNiyOKp0bjeUA+SS0xahxwGxVmaS7YUBxWZmaJjxrFLgvNTm5k
         WzNZXi6RlU00KXtxK0YDr86n2rKkTj+CC7bkIYBkOIAsO2GAzHPJpz8XqM+TOIWUQR5A
         trjeFmJvGd+w77YSbQjhCxYVY0DY+Hv9Q1tFQjx2gRCIhXEu1BqsmF/Gv+4TA6kFTDmF
         x7e/sqm6TRP9qvnZycofVOETKD0/m24KhIefotLNiXoP/rQZbRPomTo/0OAkfqldRcZQ
         dPphMvJhZjb7XJJ1UgwhT+/bobrQJm4yFPL3i2vL/0C32pABQHP4GeHIfj40QetNK64z
         ge0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAXhn0A68PEnRCOhpttDTfCPs1N3QPBZe5LjuJNbe1MzZmx0T8td
	zcGbFoKGr2wKi7Q84pYm72PWIUX4VnAQCX006nGGcSbM/wdEbSbEWGTmhLuqXvEWRVmms5I4EhD
	YTJVf2iMXB4naSdsBOgmAwZTVR1jPePa+zhLECZ72VgEM9RVJwKIILaayZZ2+OHALsw==
X-Received: by 2002:a63:ec02:: with SMTP id j2mr1286671pgh.340.1559181491523;
        Wed, 29 May 2019 18:58:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8uKsN0p0LPKZkb3PMgSgXm2pv0LgqDNTn8lzp1Zwei0/ZA5yIjzYbRTj38JlJQ7eCo92a
X-Received: by 2002:a63:ec02:: with SMTP id j2mr1286600pgh.340.1559181490677;
        Wed, 29 May 2019 18:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559181490; cv=none;
        d=google.com; s=arc-20160816;
        b=ng/rN48SbK7AvsEsgfJ2ha0bqwfj3Pj9j/u8dlIhQ/J9PvN0h4DaRct/QQuHGll8mH
         xyfHjg02EwJYIkyXhQ7S3A8z+1uQ8uv7ReDiGWkJY8SbRCZVoHSC65C2B6Zwu0uxtW45
         wse5JhUD88O4JIItvSyHy944pk/hHWIthhHN2xP57upRMQi0vTV+AieeTirU1uE2D9pn
         EaaMeNs0h6YB3E3k2aUl8y2aRtvWXp1Gv6ejy1GvH/eT8IebIEnTScmPyPZjF2No1hBK
         MI4V10/3PBtPW9d9sepwGM+u0qNOjbRsIjlJj0iE+PUzMG0pd2W6ZlfF7dm6FVgkRMWl
         ersg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=XXsLOZQadxBhSzd1txFxmx/ksVLxTCP4p3VJFs76yBk=;
        b=MTN/sOXAuolbLKM6M3EXthHkwIPwtUXfL+NlHuIJIjZqabCvJm0GEH9IKXU/3WNsHr
         KTdSAna/KzWbFOjDYNjqQ3rvNHjXYoNvE2lLcKUv0FYq3hmPnDNYaTHyV67sAfXzEREd
         3NEF56O0+wanXVYAur6ZOqJ0LrFiHsSg4eHmKF4YdHfryBthZ2eSTE+0O+1Pn45Kiu+I
         NaV0uhds4rKeSkMNYXCWEjY33nMsmBwSirNGNN7soHKLGkd/z1E/B3nUnr9x1vwNX8oO
         atjiBee374v8AYxCEQcKFXlVkpdlIqKo8WrTHtb38CVflwfH9Cap0uIKaLEoi5UEFIqW
         25/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id s184si1596902pgb.589.2019.05.29.18.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 18:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 06101ce5e0844a43a15a98856ac9e508-20190530
X-UUID: 06101ce5e0844a43a15a98856ac9e508-20190530
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 117967436; Thu, 30 May 2019 09:58:03 +0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 30 May 2019 09:58:02 +0800
Received: from [172.21.84.99] (172.21.84.99) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 30 May 2019 09:58:02 +0800
Message-ID: <1559181482.24427.18.camel@mtksdccf07>
Subject: Re: [PATCH] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Dmitry Vyukov <dvyukov@google.com>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Miles
 Chen" <miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Linux ARM"
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, "Catalin Marinas" <catalin.marinas@arm.com>
Date: Thu, 30 May 2019 09:58:02 +0800
In-Reply-To: <CACT4Y+ZwXsBk8VqvDOJGMqrbVjuZ-HfC9RG4LpgRC-9WqmQJVw@mail.gmail.com>
References: <1559027797-30303-1-git-send-email-walter-zh.wu@mediatek.com>
	 <CACT4Y+aCnODuffR7PafyYispp_U+ZdY1Dr0XQYvmghkogLJzSw@mail.gmail.com>
	 <1559122529.17186.24.camel@mtksdccf07>
	 <CACT4Y+ZwXsBk8VqvDOJGMqrbVjuZ-HfC9RG4LpgRC-9WqmQJVw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-05-29 at 12:00 +0200, Dmitry Vyukov wrote:
> > > There can be multiple qobjects in the quarantine associated with the
> > > address, right? If so, we need to find the last one rather then a
> > > random one.
> > >
> > The qobject includes the address which has tag and range, corruption
> > address must be satisfied with the same tag and within object address
> > range, then it is found in the quarantine.
> > It should not easy to get multiple qobjects have the same tag and within
> > object address range.
> 
> Yes, using the tag for matching (which I missed) makes the match less likely.
> 
> But I think we should at least try to find the newest object in
> best-effort manner.
We hope it, too.

> Consider, both slab and slub reallocate objects in LIFO manner and we
> don't have a quarantine for objects themselves. So if we have a loop
> that allocates and frees an object of same size a dozen of times.
> That's enough to get a duplicate pointer+tag qobject.
> This includes:
> 1. walking the global quarantine from quarantine_tail backwards.
It is ok.

> 2. walking per-cpu lists in the opposite direction: from tail rather
> then from head. I guess we don't have links, so we could change the
> order and prepend new objects from head.
> This way we significantly increase chances of finding the right
> object. This also deserves a comment mentioning that we can find a
> wrong objects.
> 
The current walking per-cpu list direction is from head to trail. we
will modify the direction and find the newest object.


> > > Why don't we allocate qlist_object and qlist_node in a single
> > > allocation? Doing 2 allocations is both unnecessary slow and leads to
> > > more complex code. We need to allocate them with a single allocations.
> > > Also I think they should be allocated from a dedicated cache that opts
> > > out of quarantine?
> > >
> > Single allocation is good suggestion, if we only has one allocation.
> > then we need to move all member of qlist_object to qlist_node?
> >
> > struct qlist_object {
> >     unsigned long addr;
> >     unsigned int size;
> >     struct kasan_alloc_meta free_track;
> > };
> > struct qlist_node {
> >     struct qlist_object *qobject;
> >     struct qlist_node *next;
> > };
> 
> I see 2 options:
> 1. add addr/size/free_track to qlist_node under ifdef CONFIG_KASAN_SW_TAGS
> 2. or probably better would be to include qlist_node into qlist_object
> as first field, then allocate qlist_object and cast it to qlist_node
> when adding to quarantine, and then as we iterate quarantine, we cast
> qlist_node back to qlist_object and can access size/addr.
> 
Choice 2 looks better, We first try it.

> 
> > We call call ___cache_free() to free the qobject and qnode, it should be
> > out of quarantine?
> 
> This should work.

Thanks your good suggestion.
We will implement those solution which you suggested to the second
edition.


Thanks,
Walter

