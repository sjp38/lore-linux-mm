Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C31F0C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 695C520679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oyUmP0Oa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 695C520679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E6018E0006; Tue, 30 Jul 2019 01:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097948E0003; Tue, 30 Jul 2019 01:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEFDE8E0013; Tue, 30 Jul 2019 01:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C32968E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:53:25 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h26so35281880otr.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fvJFngEdfsO2W3kgsOTyTm+u0Z70Nkc1H8YMLj8j5Fw=;
        b=VeSTc3oJO9UPieooU0NeuZb3zVueIWEhUEu/3fPCSO70kDYMhYWRseXTO5wmqtyjl3
         HG9iWgWUE0ntQ128bGEylTS83X9zpc/2Srdb8zfpnaYiIo1JzOZXOAyEBfgNJrlfC4GC
         go/92uhkC8J2aQRRbda0rV0o2mQCo6xXxlxrOS4rWySngys8EXLJrIWYLweVxjRlfdSf
         CIm1mckXLmn7BXhnkynZKhXndbN50m07Aspohv0Vpod5t9bFygf+TLdhSbVAfOD7Qc7F
         edMURSjDuxYyseWLsLv5jZtSSPdnv6iS2uGaFFtRI5t3tmjG85kfLIJRZPyoWJLagRQe
         Hgjg==
X-Gm-Message-State: APjAAAVLSJPWiVsPlxwn6O/eLJzNxddMZ6fBrcsuQMj2CL9HEsL4nZ1m
	mws5kZqd63lLIH2FEzLD8CZKboE4ux4ERsYTTISZEbQERAW4BLlTynp9oUaRwB6kbUvFCfSDwLj
	SJWdQ4Oy/OUpX7eIcIL/8/O1kmdfewXPSiNgwpYysA5Md9i+0Mnm+j80B+gU1sIm6Dw==
X-Received: by 2002:a9d:3d8a:: with SMTP id l10mr81229674otc.343.1564466005434;
        Mon, 29 Jul 2019 22:53:25 -0700 (PDT)
X-Received: by 2002:a9d:3d8a:: with SMTP id l10mr81229647otc.343.1564466004592;
        Mon, 29 Jul 2019 22:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466004; cv=none;
        d=google.com; s=arc-20160816;
        b=PG6/sXWVky3WtHGx2qu5YfHTw9DXLeqvlgaG/i8MfWBRdEAfLtPh82Xb3122agFM73
         LXIN9bhsYCt37H4fxwbj0G7K1dlGOX5Eo1Q7oTFJB1rOaT8oUQ26QXUGiV59TJcRphUc
         oXBb5p6ZYJu9DalYVF0UjIYrhN/N7Y3or6L+WnIcuL84G7YYnUhcb62RhpZxZ5fCg4kF
         amtigjNXMNi0szgbM8zNKNLZRn5W7xAtp/v+0g7jOI1ClAmYs8ZTcLjEfRtvNCViquUA
         uCJQ/+MqomxYTWZ9yz1lxFr+mrsOIgKx9p+gsdhE0GRGhifwX8LimouE4drIOYKLny9w
         Fr5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fvJFngEdfsO2W3kgsOTyTm+u0Z70Nkc1H8YMLj8j5Fw=;
        b=hndTerwD5l+7vaPGhXpoDFPS+Ibm8ksXFPGuLTPPbp+ssSs+w3FbfUrSlYU6ezCXxl
         DomYPxOWKltVBzzpOdU3syQDirBwr+Fp1aSYkC3bp6fB7yeXcxvkjFfUtsXMbPvjLGfJ
         TZv88WEbqTLVl3NaMHW2wruXyS0Zdj+rnju9v31QJ/WBxB82VoGllmNgcAUqXnPKwyVL
         g1jVp1vDF77BG5uXxcAg2EqbrG1x/7NsJjgrI6LPPvhQO1LVBATZR0ElIoUAvE+c6f0N
         G5VNNAbZhXdwYyBi8A1mPXeertc3gf5vlrNaQEjWp5MKP/t5xp0Kx8BLcYZQds1mYwuZ
         9THQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oyUmP0Oa;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor29102638oiv.10.2019.07.29.22.53.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 22:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oyUmP0Oa;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fvJFngEdfsO2W3kgsOTyTm+u0Z70Nkc1H8YMLj8j5Fw=;
        b=oyUmP0OaDSd1kv8EM1Q+KjT8O4AZ2byfX9KTAQdo8vEG9BTZLr890gRxrCUYo1lL1i
         EEqCX2tG6UR2ecWJ2LzD6GEkvRlKwbiBiQ1a5gNCn5r4qCqHZQx920Vq/m2mRw+ut67h
         ahJETXpHIYnPSv6hFbxPq22HL5CtutHiCcpM+Bfebc4vFpYk4sc07KOwimiArpNzxs8P
         te4EptKYdQKk8pyfd7NA3ghlHnbxj6/INAgCPjiahERcx8UCvkoQPek3MAyeNwfkFM5L
         OYrEWE12PYv+z8F/itW3xNL8jBW7A3ut35CcRCLH9+ZpHEFu/NKBgxKmpCn/G3M8P+BT
         MQSQ==
X-Google-Smtp-Source: APXvYqweAY9kDNHm+conRB7sM/ifS33fnOjg74ZBXOYMRznY3pVSm2YUiPKJ5Kdcn9KhGRUAS4Scj8g7qgB/Lgr6WGc=
X-Received: by 2002:aca:4d12:: with SMTP id a18mr126968oib.33.1564466004259;
 Mon, 29 Jul 2019 22:53:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <20190726072637.GC2739@techsingularity.net>
 <CAD7_sbHwjN3RY+ofgWvhQFJdxhCC4=gsMs194=wOH3tKV-qSUg@mail.gmail.com> <20190729083440.GE2739@techsingularity.net>
In-Reply-To: <20190729083440.GE2739@techsingularity.net>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 30 Jul 2019 13:53:13 +0800
Message-ID: <CAD7_sbE36NZbpABN+CcJv60y0-qD=nCgKNPkWxY2Xbx1E+nvhA@mail.gmail.com>
Subject: Re: [PATCH 00/10] make "order" unsigned int
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, vbabka@suse.cz, 
	Qian Cai <cai@lca.pw>, aryabinin@virtuozzo.com, osalvador@suse.de, 
	rostedt@goodmis.org, mingo@redhat.com, pavel.tatashin@microsoft.com, 
	rppt@linux.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 4:34 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Sun, Jul 28, 2019 at 12:44:36AM +0800, Pengfei Li wrote:
> > On Fri, Jul 26, 2019 at 3:26 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > >
> >
> > Thank you for your comments.
> >
> > > On Fri, Jul 26, 2019 at 02:42:43AM +0800, Pengfei Li wrote:
> > > > Objective
> > > > ----
> > > > The motivation for this series of patches is use unsigned int for
> > > > "order" in compaction.c, just like in other memory subsystems.
> > > >
> > >
> > > Why? The series is relatively subtle in parts, particularly patch 5.
> >
> > Before I sent this series of patches, I took a close look at the
> > git log for compact.c.
> >
> > Here is a short history, trouble you to look patiently.
> >
> > 1) At first, "order" is _unsigned int_
> >
> > The commit 56de7263fcf3 ("mm: compaction: direct compact when a
> > high-order allocation fails") introduced the "order" in
> > compact_control and its type is unsigned int.
> >
> > Besides, you specify that order == -1 is the flag that triggers
> > compaction via proc.
> >
>
> Yes, specifying that compaction in that context is for the entire zone
> without any specific allocation context or request.

Yes

>
> > 2) Next, because order equals -1 is special, it causes an error.
> >
> > The commit 7be62de99adc ("vmscan: kswapd carefully call compaction")
> > determines if "order" is less than 0.
> >
> > This condition is always true because the type of "order" is
> > _unsigned int_.
> >
> > -               compact_zone(zone, &cc);
> > +               if (cc->order < 0 || !compaction_deferred(zone))
> >
> > 3) Finally, in order to fix the above error, the type of the order
> > is modified to _int_
> >
> > It is done by commit: aad6ec3777bf ("mm: compaction: make
> > compact_control order signed").
> >
> > The reason I mention this is because I want to express that the
> > type of "order" is originally _unsigned int_. And "order" is
> > modified to _int_ because of the special value of -1.
> >
>
> And in itself, why does that matter?

The -1 makes order is int, which breaks the consistency of the type of order.

>
> > If the special value of "order" is not a negative number (for
> > example, -1), but a number greater than MAX_ORDER - 1 (for example,
> > MAX_ORDER), then the "order" may still be _unsigned int_ now.
> >
>
> Sure, but then you have to check that every check on order understands
> the new special value.
>

Since this check is done by is_via_compact_memory(), it is easy to modify the
special value being checked.

I have checked every check many times and now I need some reviews from
the community.

> > > There have been places where by it was important for order to be able to
> > > go negative due to loop exit conditions.
> >
> > I think that even if "cc->order" is _unsigned int_, it can be done
> > with a local temporary variable easily.
> >
> > Like this,
> >
> > function(...)
> > {
> >     for(int tmp_order = cc->order; tmp_order >= 0; tmp_order--) {
> >         ...
> >     }
> > }
> >
>
> Yes, it can be expressed as unsigned but in itself why does that justify
> the review of a large series?

At first glance it seems that this series of patches is large. But at least
half of it is to modify the corresponding trace function. And you can see
that except patch 4 and patch 5, other patches only modify the type of
order.

Even for patch 5 with function modifications, the modified code has only
about 50 lines.

> There is limited to no performance gain
> and functionally it's equivalent.

This is just clean up. And others have done similar work before.

commit d00181b96eb8 ("mm: use 'unsigned int' for page order")
commit 7aeb09f9104b ("mm: page_alloc: use unsigned int for order in
more places")

>
> > > If there was a gain from this
> > > or it was a cleanup in the context of another major body of work, I
> > > could understand the justification but that does not appear to be the
> > > case here.
> > >
> >
> > My final conclusion:
> >
> > Why "order" is _int_ instead of unsigned int?
> >   => Because order == -1 is used as the flag.
> >     => So what about making "order" greater than MAX_ORDER - 1?
> >       => The "order" can be _unsigned int_ just like in most places.
> >
> > (Can we only pick -1 as this special value?)
> >
>
> No, but the existing code did make that choice and has been debugged
> with that decision.

But this choice breaks the consistency of the order type, isn't it?

Because the check is done in is_via_compact_memory() , you don't need to
worry too much about the modification.

>
> > This series of patches makes sense because,
> >
> > 1) It guarantees that "order" remains the same type.
> >
>
> And the advantage is?

As I mentioned earlier, maintaining the consistency of the order type.

Do you really like to see such a call stack?

__alloc_pages_slowpath(unsigned int order, ...)
/* The type has changed! */
  => should_compact_retry(int order, ...)
    => compaction_zonelist_suitable(int order, ...)
      => __compaction_suitable(int order, ...)
/* The type has changed again! */
         => zone_watermark_ok(unsigned int order, ...)

The type of order has changed twice!

According to commit d00181b96eb8 and commit 7aeb09f9104b, we
want the order type to be the same.

There are currently only five functions in page_alloc.c that use int
order, and three of them are related to compaction.

>
> > No one likes to see this
> >
> > __alloc_pages_slowpath(unsigned int order, ...)
> >  => should_compact_retry(int order, ...)            /* The type changed */
> >   => compaction_zonelist_suitable(int order, ...)
> >    => __compaction_suitable(int order, ...)
> >     => zone_watermark_ok(unsigned int order, ...)   /* The type
> > changed again! */
> >
> > 2) It eliminates the evil "order == -1".
> >
> > If "order" is specified as any positive number greater than
> > MAX_ORDER - 1 in commit 56de7263fcf3, perhaps no int order will
> > appear in compact.c until now.
> >
>
> So, while it is possible, the point still holds. There is marginal to no
> performance advantage (some CPUs perform fractionally better when an
> index variable is unsigned rather than signed but it's difficult to
> measure even when you're looking for it). It'll take time to review and
> then debug the entire series. If this was in the context of a larger
> functional enablement or performance optimisation then it would be
> worthwhile but as it is, it looks more like churn for the sake of it.

My summary,

1) This is just clean up. And others have done similar work before.
commit d00181b96eb8 ("mm: use 'unsigned int' for page order")
commit 7aeb09f9104b ("mm: page_alloc: use unsigned int for order in
more places")

2) Thanks to is_via_compact_memory(), it is easy to modify the
special value -1 to another value.

3) Not much modification.
Function code modified about 50 lines, and only in patch 4 and patch 5.
At least half of it is to modify the corresponding trace function

>
> --
> Mel Gorman
> SUSE Labs

Sincerely thank you for your detailed comments.

--
Pengfei

