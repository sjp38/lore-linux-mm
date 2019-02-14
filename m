Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE9EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:13:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C42F222C9
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:13:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Xa+qZY+m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C42F222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2BFB8E0004; Thu, 14 Feb 2019 10:13:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB2838E0001; Thu, 14 Feb 2019 10:13:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7A4D8E0004; Thu, 14 Feb 2019 10:13:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B78C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:13:42 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id m52so5535245otc.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:13:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iJI/pk5H55mfRvQVlZ1QB6KQyS4XiuvbQpyQ9QHp3cg=;
        b=twgMr08M7MBHr4cDSx/+EJhxXPbgAapZqJSlZ3b4mU5kVzXe7q7LskpvFNj8RLy7G6
         hqphOuhpbqpEfhg1clTwtytmev2xM4ZBxKXbPbGxsgVCD1H1fz48ay0/W1v1d3hyYf0k
         hlN+rVC6k+RzmsQofi+MMZ3XMBA6C6sspCKlhkyFSLX4OseXSuj7DfOYmKb4quuVowrh
         C3fBJOjFbC1aIMtYtFFWMUxIkUtaCQrsQr/3IW+N9GFuFpfoIk3G3XwHO2aC9Sm/e8Ww
         qyGLOuOkExh4T5+/pI+HZHnD2uJuJho8DUoFStGcALemDI/FFyV/+pQM9za3nKYjBT7f
         6DBQ==
X-Gm-Message-State: AHQUAubW1Q9PQsY1YODh9YwWVlO0PKHWPzmukE9ZJn8ftEGX2OmV5qnU
	gYhDelUR+U7qUxqRV1v2IkBAAD9Lw8CQFeYIruJAwnmkg/9M9p3s1sUyLgci1S/jhhS7h3/Tiyt
	cz5Vq3oWZZsIhZaCEkVT0qD/WQ7R/aZE7mHndZqoXDwsQ54AEvoVbAd8utXZ0ArGqFcn+YeFJE9
	f66vWi8EXy3cZi1yUZ6gcAUuUI91hYxkNbE2UFziF3zKjzS3NJpdb7ddd3FE+1AdI+qRoimf+Py
	GwOO5qtoCzTQqdxeqWei5U+Ja7uGwiRmdf4oscx/cOSz3ThhH9Up/Lc1p9R7KkfT8R5aW4TpYCa
	g70W13yeZ9n9deSwPe38YzF0bR+LdAsv3xllzgpgObpc5dNn/t4eQeXNx4deZDoZmC0XqFcduCl
	3
X-Received: by 2002:aca:538f:: with SMTP id h137mr2801525oib.54.1550157222262;
        Thu, 14 Feb 2019 07:13:42 -0800 (PST)
X-Received: by 2002:aca:538f:: with SMTP id h137mr2801479oib.54.1550157221512;
        Thu, 14 Feb 2019 07:13:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550157221; cv=none;
        d=google.com; s=arc-20160816;
        b=t0tyPE0fAs5flwo26/I+4HA8P8YDU7ikDfaOLyYiwd2I1DrBNiEPG7ZAeSKwnaL6RV
         NjgqGNQs5H/rWxkTendd3U5vFnN54GqmwQo+buG0ppSZWMY9PwbjN+VM3Hujxjzgh5eI
         OWueYKvQ8nR1A2WeJHh7XAfMYatwstDOGYtLDFbkQHvxvm5kns86QB331UUZK8p8GhlE
         OzY+jWT9hBX9dxL00cZrOacyD0MEyhAAb4inZRmmVXBaCIv8k0Y03E9GbqcIlM0PXC8j
         p2C4GIOF8Ej2RdMw7ijo6vFmjziZfwsQbktvDpJGjXVOoT3BqUKiTWd70Xrj2VyKBtAJ
         VUfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iJI/pk5H55mfRvQVlZ1QB6KQyS4XiuvbQpyQ9QHp3cg=;
        b=DTC52ADl6iq+b/MVAlWwmhCwWZyExanQ+WJPKP5boj6TGGhuS/CptaHFz1yxho+wmF
         i/vF1cPb5KZwq96an9zXoklTMmfQIiB7ZnHMaqGZV375wGXkBolf6mLbYYT/1krAHOYS
         VpEpA8BHvjxo/XWsvmQ7CqaFBXN6BJQjtB9+5gi6e+IXCxagE+6fUGw16En5U29d0N+A
         ETJcd3qoa5lPRl97FpF+9El/jlM+he7bJopUWBAZnCoEG77SPbm2ye68lYRUWt1dBTro
         vZEvFFWZSHhaj1oBTC9Umu/g4NiVeMxAJojOdS6XERKz+gTVGgQcL4IYu1fI2RETa2OY
         2jyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Xa+qZY+m;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u84sor1542257oib.6.2019.02.14.07.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 07:13:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Xa+qZY+m;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iJI/pk5H55mfRvQVlZ1QB6KQyS4XiuvbQpyQ9QHp3cg=;
        b=Xa+qZY+mcalye0fRh8JiCRY2VzHP4nXzMty8/xvOdxDYelcPykB9tFfdPE2TQXzifQ
         d3q5UWieKFooAx/BcbMsO8mIiEEBlmGfD6vEc3FePMF37o0MFEFF6XTrvBCT2PWLCr3P
         ZTDBf3WNDv/5KaCBZsKtp4yWNI+kAFIj9svQHfSod0HLzTZzvD4T/1JS6tzh8iWhw/64
         I1cfcI5j52B0PjiRHT3td0/QJUlo9DfcivVEpp7fbtjeiZCOb5nQMkcDfVaa6oV43eyQ
         mkjlnJPHB5EH2nEXv9FEZSjIdlSUx1ebc+YfXKVLUhJH303K6d4Yuvpz4rQ2+7PwwFeB
         xOzw==
X-Google-Smtp-Source: AHgI3IYtH6Br7+jtnzndSJDWGG8uEAmaoG1A+RjcD/4JuI2o3aAA0GTtYjkIUK8162ciwLyeee9wolUaXeFMqrH29Ko=
X-Received: by 2002:aca:3806:: with SMTP id f6mr1973512oia.47.1550157220765;
 Thu, 14 Feb 2019 07:13:40 -0800 (PST)
MIME-Version: 1.0
References: <20190213204157.12570-1-jannh@google.com> <CAKgT0Uc7wheUjStv5a4BSNv_=-iu1Ttdj9f_10CdR_oc2BhVig@mail.gmail.com>
In-Reply-To: <CAKgT0Uc7wheUjStv5a4BSNv_=-iu1Ttdj9f_10CdR_oc2BhVig@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 14 Feb 2019 16:13:14 +0100
Message-ID: <CAG48ez0v7QwtCKDs5vgRJht8yfZR5nudEpkMOLaDX-=47WeFqA@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
To: Alexander Duyck <alexander.duyck@gmail.com>
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

On Wed, Feb 13, 2019 at 11:42 PM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Feb 13, 2019 at 12:42 PM Jann Horn <jannh@google.com> wrote:
> > The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> > number of references that we might need to create in the fastpath later,
> > the bump-allocation fastpath only has to modify the non-atomic bias value
> > that tracks the number of extra references we hold instead of the atomic
> > refcount. The maximum number of allocations we can serve (under the
> > assumption that no allocation is made with size 0) is nc->size, so that's
> > the bias used.
> >
> > However, even when all memory in the allocation has been given away, a
> > reference to the page is still held; and in the `offset < 0` slowpath, the
> > page may be reused if everyone else has dropped their references.
> > This means that the necessary number of references is actually
> > `nc->size+1`.
> >
> > Luckily, from a quick grep, it looks like the only path that can call
> > page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> > requires CAP_NET_ADMIN in the init namespace and is only intended to be
> > used for kernel testing and fuzzing.
>
> Actually that has me somewhat concerned. I wouldn't be surprised if
> most drivers expect the netdev_alloc_frags call to at least output an
> SKB_DATA_ALIGN sized value.
>
> We probably should update __netdev_alloc_frag and __napi_alloc_frag so
> that they will pass fragsz through SKB_DATA_ALIGN.

Do you want to do a separate patch for that? I'd like to not mix
logically separate changes in a single patch, and I also don't have a
good understanding of the alignment concerns here.

> > To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> > `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> > writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> > with a vector consisting of 15 elements containing 1 byte each.
> >
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Jann Horn <jannh@google.com>
> > ---
> >  mm/page_alloc.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 35fdde041f5c..46285d28e43b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> >                 /* Even if we own the page, we do not use atomic_set().
> >                  * This would break get_page_unless_zero() users.
> >                  */
> > -               page_ref_add(page, size - 1);
> > +               page_ref_add(page, size);
> >
> >                 /* reset page count bias and offset to start of new frag */
> >                 nc->pfmemalloc = page_is_pfmemalloc(page);
> > -               nc->pagecnt_bias = size;
> > +               nc->pagecnt_bias = size + 1;
> >                 nc->offset = size;
> >         }
> >
> > @@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> >                 size = nc->size;
> >  #endif
> >                 /* OK, page count is 0, we can safely set it */
> > -               set_page_count(page, size);
> > +               set_page_count(page, size + 1);
> >
> >                 /* reset page count bias and offset to start of new frag */
> > -               nc->pagecnt_bias = size;
> > +               nc->pagecnt_bias = size + 1;
> >                 offset = size - fragsz;
> >         }
>
> If we already have to add a constant it might be better to just use
> PAGE_FRAG_CACHE_MAX_SIZE + 1 in all these spots where you are having
> to use "size + 1" instead of "size". That way we can avoid having to
> add a constant to a register value and then program that value.
> instead we can just assign the constant value right from the start.

I doubt that these few instructions make a difference, but sure, I can
send a v2 with that changed.

