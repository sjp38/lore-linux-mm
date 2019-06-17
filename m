Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59DECC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18F3D217D4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:00:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18F3D217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE3746B0007; Mon, 17 Jun 2019 00:00:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B950D8E0003; Mon, 17 Jun 2019 00:00:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAAC58E0001; Mon, 17 Jun 2019 00:00:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7394A6B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:00:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so6285840pfn.3
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=XnEdrBkKM7udA2kzVesWGzGVoOtWxKegmT2E9+/IH6Q=;
        b=FIS5kuO3/0eY5zUWTIEcbrgeHmrOx5Kzx9ZVIux5weAxqty95oGZW1rUKKy+KBAYjt
         tSBpRcbTaU5O5l2CBXno7cMrgsyH9H9X/0vsF5FOcyoctBu5k/xJicV4XOzbTvFdn3w+
         7SxiZFGhH8HyqCOgHP+Uy/wfNvhFX/zvJYZtyE/LPygbeKlg9J2SoVaLsL1IbGTaKh8O
         Z42x0hcBnG0NEQln+QojBGqrBL4hOygvTAxbOeZp/3lG+0/bCAQvlcV3m1B9XJ+8T3nl
         FsYeD5MzOr1Rfh6L+4J5eU4gqlJZsiaWykStGmEuIWfgsXlHiixEXkIcImuvZHr2ot6S
         n1XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAWX/vdGh1Sbn6eannMoq5QMo0T2NGcQjBRIexqQ49Uf2/dt9JRN
	DRlO+PbPDW9vYfBp8xGJalFychT8m2ZIdQLbQqDT1SQ7UPTcCp679mCjY/i4ObvqJAblAYBMj+c
	eFkS6qVNm14OjCh4ilzcr1pOboLDDy4O7MY4fnezbtpU4fp4sbBwy0DyBWYT68h0iaw==
X-Received: by 2002:a63:c5:: with SMTP id 188mr21875367pga.108.1560744023924;
        Sun, 16 Jun 2019 21:00:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyicCgcs3GruBVXyLfJpDko0Gp5bvHmx2YSmJ1MseNPwImRzXcv8nAZY70/t807eQj2OuKB
X-Received: by 2002:a63:c5:: with SMTP id 188mr21875301pga.108.1560744023074;
        Sun, 16 Jun 2019 21:00:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560744023; cv=none;
        d=google.com; s=arc-20160816;
        b=AhCu3ZEQJD5ZF78xfB1DZw3Mx13z1SPzH1BO/lIUUOYpKalvmQNUvY1dFo6lp5uhy3
         iRVn/ypV1bmOYglIFiNYmytyadqbn0eAdcGoRlQ8TeGd5vAgMZA97exxAIqWWEdMwLoe
         NmX1rii4C0kgdngQTA2xsbCR+Dbtbsw06nMRwr0G6J6NOj44xz6qJgEFZeim5X0GWrla
         1DylxhPso8C9SDnKiR28b4YSUyKWmh4o/IQd5nb/bYjSTUgBKOw0TZqUMf1xpmuIoYSE
         lxBU1CjRbuzxQ9L+9p8LgpYKp7VyaXKdNvtvF3hp9J/jrrcWcBBstz6I9tL7OLYd6CcL
         XFLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=XnEdrBkKM7udA2kzVesWGzGVoOtWxKegmT2E9+/IH6Q=;
        b=s/akx6mUlMkGLvi1/WRaxei5OmzxW7a4C5miJv6shrO08JaDzOzxtCLNXeq6oTXhVt
         KTDyt4nBvY4i/RPNzoI5GU0kx4x44FPyrZ36pEkYe3LrBxy1fp0m0FcO+SYisiqXKpGC
         HHA/TRRyP8nV+6YV4yvQ1pXH+q3/H5t1g7PL6eItuzrUWKAV+LgLfYrwKmGunkT4OKaE
         Ov05lqMWXyYDQPikkgv4NcDt1iQzaQUovoIsHwsqerDGvt0U2SAP7jCdgpT/zV2B6+2v
         RxtrZjNekAbn3Iqj82uCfgiemNq9obkP3x6dFQsqECi4lQiFwgk+4r3ZnMHCB8WWSlZ1
         2ung==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id a2si9982184pgj.54.2019.06.16.21.00.22
        for <linux-mm@kvack.org>;
        Sun, 16 Jun 2019 21:00:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 4f8413c5163f45fab280b7f808ef34f4-20190617
X-UUID: 4f8413c5163f45fab280b7f808ef34f4-20190617
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1298173636; Mon, 17 Jun 2019 12:00:19 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 17 Jun 2019 12:00:18 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 17 Jun 2019 12:00:17 +0800
Message-ID: <1560744017.15814.49.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>
CC: Alexander Potapenko <glider@google.com>, Dmitry Vyukov
	<dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	<kasan-dev@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Mon, 17 Jun 2019 12:00:17 +0800
In-Reply-To: <1560479520.15814.34.camel@mtksdccf07>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
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

On Fri, 2019-06-14 at 10:32 +0800, Walter Wu wrote:
> On Fri, 2019-06-14 at 01:46 +0800, Walter Wu wrote:
> > On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> > > 
> > > On 6/13/19 11:13 AM, Walter Wu wrote:
> > > > This patch adds memory corruption identification at bug report for
> > > > software tag-based mode, the report show whether it is "use-after-free"
> > > > or "out-of-bound" error instead of "invalid-access" error.This will make
> > > > it easier for programmers to see the memory corruption problem.
> > > > 
> > > > Now we extend the quarantine to support both generic and tag-based kasan.
> > > > For tag-based kasan, the quarantine stores only freed object information
> > > > to check if an object is freed recently. When tag-based kasan reports an
> > > > error, we can check if the tagged addr is in the quarantine and make a
> > > > good guess if the object is more like "use-after-free" or "out-of-bound".
> > > > 
> > > 
> > > 
> > > We already have all the information and don't need the quarantine to make such guess.
> > > Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> > > otherwise it's use-after-free.
> > > 
> > > In pseudo-code it's something like this:
> > > 
> > > u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> > > 
> > > if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> > > 	// out-of-bounds
> > > else
> > > 	// use-after-free
> > 
> > Thanks your explanation.
> > I see, we can use it to decide corruption type.
> > But some use-after-free issues, it may not have accurate free-backtrace.
> > Unfortunately in that situation, free-backtrace is the most important.
> > please see below example
> > 
> > In generic KASAN, it gets accurate free-backrace(ptr1).
> > In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> > programmer misjudge, so they may not believe tag-based KASAN.
> > So We provide this patch, we hope tag-based KASAN bug report is the same
> > accurate with generic KASAN.
> > 
> > ---
> >     ptr1 = kmalloc(size, GFP_KERNEL);
> >     ptr1_free(ptr1);
> > 
> >     ptr2 = kmalloc(size, GFP_KERNEL);
> >     ptr2_free(ptr2);
> > 
> >     ptr1[size] = 'x';  //corruption here
> > 
> > 
> > static noinline void ptr1_free(char* ptr)
> > {
> >     kfree(ptr);
> > }
> > static noinline void ptr2_free(char* ptr)
> > {
> >     kfree(ptr);
> > }
> > ---
> > 
> We think of another question about deciding by that shadow of the first
> byte.
> In tag-based KASAN, it is immediately released after calling kfree(), so
> the slub is easy to be used by another pointer, then it will change
> shadow memory to the tag of new pointer, it will not be the
> KASAN_TAG_INVALID, so there are many false negative cases, especially in
> small size allocation.
> 
> Our patch is to solve those problems. so please consider it, thanks.
> 
Hi, Andrey and Dmitry,

I am sorry to bother you.
Would you tell me what you think about this patch?
We want to use tag-based KASAN, so we hope its bug report is clear and
correct as generic KASAN.

Thanks your review.
Walter

