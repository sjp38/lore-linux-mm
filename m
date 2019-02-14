Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 456B2C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3CFB222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:37:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GzBHlyYG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3CFB222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 209668E0002; Thu, 14 Feb 2019 10:37:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9148E0001; Thu, 14 Feb 2019 10:37:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CFA28E0002; Thu, 14 Feb 2019 10:37:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC0078E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:37:34 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p66so10926386itc.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:37:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z+/VBdnNZSL+dtF784MTuvLnHvY3T/rWFSZ46f+0SO8=;
        b=tqbe4w6OGdsd3i2c857l1gjgwfIL+YJ8GCKLuc2oVOFmWdWEWGLOgh/h6Od9ZMzX66
         QxSb6R6NxcW98fJTDSqyvfFAIUQkA1cAYC5fFwI8nfJyWP59LyS0KaD6F/gGhJiaL7mu
         tHgm57WvafU9/KakaHuDNrXPsGOSE8dK0wJlw1hqvfInaYTAwr5X1BlxW2SxBwN2Vw1E
         j7b2rYkSDcAJ5FUqrMp5nj1OKJ/Dn/wPcEhgfH+C5d4WVtWrMNTdUUhrgpSyNPExBnvJ
         xiOBMWyAJqFT1U+7/xeFNJZGb1TCpLkN+L6/+f/MM1vs9EI50EK7/AXLidYpK/x65FtU
         p7lg==
X-Gm-Message-State: AHQUAualxSmKeFBwr+VAe0xXgdB2YxsGqsNNOqGUmbafANskL/EU3TKs
	JWpkAIvkRkMsAN42TmJaKxR0PSuBl3AYU6C6FZLrxhtTHIW7XMGJfdiB+3HJqFZuqpb9XG7cfvA
	sIfNO94p+LbEUfJDoBZA+FoOaNwmG8Rp0w4h49pRoC0bZ257084dSeC7uGk0dOaX8Zx5HVtpBsn
	OdHjajNFBIZLvVXE+Ia1tnYeWrCGaI30W4U71Ml+ivLqqS6ZNRxV0tUmjU0XnHvBYO4G7Y9s8ge
	6sVWSptY0rFzt8vEdvjD9kSPCY7eg8j5l9Aeq4+HPDk1G5YGL1OV110tRoeWQ+01Pc4+ypkZneB
	r7RKVJf27akD/xpZU81e4CNWejsfV8ZNjJFfz9kCWtbqgD6cX8btVKpsfbxK3T2mt/lv8wRvFT0
	l
X-Received: by 2002:a5e:a60f:: with SMTP id q15mr2672217ioi.140.1550158654650;
        Thu, 14 Feb 2019 07:37:34 -0800 (PST)
X-Received: by 2002:a5e:a60f:: with SMTP id q15mr2672161ioi.140.1550158653621;
        Thu, 14 Feb 2019 07:37:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550158653; cv=none;
        d=google.com; s=arc-20160816;
        b=YymD8nCSIRX0CbtG5Y6RO5mRPgFIfArP6V7KpK+ifPF1mYEiBf7msji/0hbeV7yrvQ
         2tnSzPU6iHlt64d+YOrdLJF2mbf1K0L3u/cSChrI3kF0vq6xelmPgKr4AsZLhcmbxei9
         WATgdo/5pw0ORTfyIsMhBtzNqeelvWYcVyxwUZUHf3DbtzpfFIgi9IVjLKufn8+wX9YZ
         bF/SdvPqP9iHBIwHh1Ta2TuCuWkkUWvTDhgS0u1X5Qbsrrote8XSMRK7d/yxTLY9dPzH
         xzgDzPzL7MReX9wOl+bvwWh5YKp7BuF/6640MfcWDyv/uXKLBsU5eZvPdcjXtkRX9TmH
         mpOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Z+/VBdnNZSL+dtF784MTuvLnHvY3T/rWFSZ46f+0SO8=;
        b=TgmQEJEAK36Jl/93w+JZfiUnvKH3YhuDvUB7zKQ+u9C3PmdmClNc3uVg+ZiSmTT06f
         51TxaZPTikRsl1AZ98CBMNI/IoBiM7NdV67xIp/YxspJtxAu1Sm5b2ps5BM/xMNne3AF
         c9l7Wfy9mAgsX2XbSE62qhkRa20GsyJ55U6Tn5aMqxTXq/IXMl/E8LF7CKa3g62r17nM
         Snh++Oad2YkGVxeHrGSbg/gyxBtsWNgGaDFtjxFYlfFd51hOE2q/y7h0jYsqWsHvuI1G
         hfREteshd0Fllcnx9ZDy2O/cpTLFrzpuG86SiZJwc/ujVPQCygUPt+D8Qm8jVWFSZdvB
         MapA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GzBHlyYG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l128sor1412614ioa.69.2019.02.14.07.37.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 07:37:33 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GzBHlyYG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z+/VBdnNZSL+dtF784MTuvLnHvY3T/rWFSZ46f+0SO8=;
        b=GzBHlyYG+AOJ+gbIGyLgf8XMFJTAVzqZOf/6sDAinnVQnsd9DVqJ/D71AUMNuM+qq0
         c1VOmwYHlxtl89Ox+4Yw4zQ5kQKT2m5Sj9+z37qcArbBM5+Eqelqal8DkB7V0EuE+5Yw
         pBGZIeBpnJQb6Tu0GI++AtBcNvZtzg60HmnVSoTRSCdbPDy/KZIKfERYYYgt9p0B4782
         fkVQsVd5HeaXI+6nICGCiAZHTqmGgZDUIcbxS/ev7zKXvqTzK1KQ2bxnwxSt04o3i9aP
         uPqanevtj3bG7BT6jzk8kfOBr+7ZKlJfn9xAL2kse7mcHfA5XVlHnZsHyWp5iUKvFYx5
         1gHA==
X-Google-Smtp-Source: AHgI3IaIEW57zI7tgCujKKMaaoc2liycZ5BjW1rEDjlu6jRy0Zlc9g6mTM0kJK81e2UL4o7VxaPRUAIkegYnPw/nsvg=
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr2898317iog.68.1550158653095;
 Thu, 14 Feb 2019 07:37:33 -0800 (PST)
MIME-Version: 1.0
References: <20190213204157.12570-1-jannh@google.com> <CAKgT0Uc7wheUjStv5a4BSNv_=-iu1Ttdj9f_10CdR_oc2BhVig@mail.gmail.com>
 <CAG48ez0v7QwtCKDs5vgRJht8yfZR5nudEpkMOLaDX-=47WeFqA@mail.gmail.com>
In-Reply-To: <CAG48ez0v7QwtCKDs5vgRJht8yfZR5nudEpkMOLaDX-=47WeFqA@mail.gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 14 Feb 2019 07:37:21 -0800
Message-ID: <CAKgT0Ue99Zj88m_mfvnaj3_WspkzfABFsH==B_0X0s85z9Xvaw@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
To: Jann Horn <jannh@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, 
	Oscar Salvador <osalvador@suse.de>, Mel Gorman <mgorman@techsingularity.net>, 
	Aaron Lu <aaron.lu@intel.com>, Netdev <netdev@vger.kernel.org>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 7:13 AM Jann Horn <jannh@google.com> wrote:
>
> On Wed, Feb 13, 2019 at 11:42 PM Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
> > On Wed, Feb 13, 2019 at 12:42 PM Jann Horn <jannh@google.com> wrote:
> > > The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> > > number of references that we might need to create in the fastpath later,
> > > the bump-allocation fastpath only has to modify the non-atomic bias value
> > > that tracks the number of extra references we hold instead of the atomic
> > > refcount. The maximum number of allocations we can serve (under the
> > > assumption that no allocation is made with size 0) is nc->size, so that's
> > > the bias used.
> > >
> > > However, even when all memory in the allocation has been given away, a
> > > reference to the page is still held; and in the `offset < 0` slowpath, the
> > > page may be reused if everyone else has dropped their references.
> > > This means that the necessary number of references is actually
> > > `nc->size+1`.
> > >
> > > Luckily, from a quick grep, it looks like the only path that can call
> > > page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> > > requires CAP_NET_ADMIN in the init namespace and is only intended to be
> > > used for kernel testing and fuzzing.
> >
> > Actually that has me somewhat concerned. I wouldn't be surprised if
> > most drivers expect the netdev_alloc_frags call to at least output an
> > SKB_DATA_ALIGN sized value.
> >
> > We probably should update __netdev_alloc_frag and __napi_alloc_frag so
> > that they will pass fragsz through SKB_DATA_ALIGN.
>
> Do you want to do a separate patch for that? I'd like to not mix
> logically separate changes in a single patch, and I also don't have a
> good understanding of the alignment concerns here.

You could just include it as a separate patch with your work.
Otherwise I will get to it when I have time.

The point is the issue you pointed out will actually cause other
issues if the behavior is maintained since you shouldn't be getting
unaligned blocks out of the frags API anyway.

> > > To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> > > `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> > > writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> > > with a vector consisting of 15 elements containing 1 byte each.
> > >
> > > Cc: stable@vger.kernel.org
> > > Signed-off-by: Jann Horn <jannh@google.com>
> > > ---
> > >  mm/page_alloc.c | 8 ++++----
> > >  1 file changed, 4 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 35fdde041f5c..46285d28e43b 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> > >                 /* Even if we own the page, we do not use atomic_set().
> > >                  * This would break get_page_unless_zero() users.
> > >                  */
> > > -               page_ref_add(page, size - 1);
> > > +               page_ref_add(page, size);
> > >
> > >                 /* reset page count bias and offset to start of new frag */
> > >                 nc->pfmemalloc = page_is_pfmemalloc(page);
> > > -               nc->pagecnt_bias = size;
> > > +               nc->pagecnt_bias = size + 1;
> > >                 nc->offset = size;
> > >         }
> > >
> > > @@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> > >                 size = nc->size;
> > >  #endif
> > >                 /* OK, page count is 0, we can safely set it */
> > > -               set_page_count(page, size);
> > > +               set_page_count(page, size + 1);
> > >
> > >                 /* reset page count bias and offset to start of new frag */
> > > -               nc->pagecnt_bias = size;
> > > +               nc->pagecnt_bias = size + 1;
> > >                 offset = size - fragsz;
> > >         }
> >
> > If we already have to add a constant it might be better to just use
> > PAGE_FRAG_CACHE_MAX_SIZE + 1 in all these spots where you are having
> > to use "size + 1" instead of "size". That way we can avoid having to
> > add a constant to a register value and then program that value.
> > instead we can just assign the constant value right from the start.
>
> I doubt that these few instructions make a difference, but sure, I can
> send a v2 with that changed.

You would be surprised. They all end up adding up over time.

