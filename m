Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCF4DC28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:19:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E4582075B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:19:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kmgXYItR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E4582075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AD086B026A; Wed,  5 Jun 2019 22:19:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E1B6B026C; Wed,  5 Jun 2019 22:19:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023E36B026E; Wed,  5 Jun 2019 22:19:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D891D6B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 22:19:50 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y5so485065ioj.10
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 19:19:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DTWH24yA/1C8wqtT9jqxaOXK4VdWlElUekSQr6wCUNk=;
        b=K7F8dLda7GAsrl2PsVoR1+0F8ypV3D/FSfc2z4nCyfNubea4BUJ0OrmAIZHyImFjkH
         jEmd237xCIPwOaw/Lpfru/JtS9bRyFZyyDlgomeQxqblz715CbNsLgz2E5IA5tNUUpdI
         2OXnbqjqTyYdG+MTp7/oVbvs7kYqiI4FmB9X7UYaPSSNtUQcL6qMIe72URgS0Xv5jvd7
         BKhdgfUOudZGLJXui/B9SSvFTp+cLNR3e9HQwMiTy2jsQmFK4yZQOnOCdmpdl2CulN3+
         R+cr72hb4WkbdVOIMyhLx1UFPyYyWYvvAPhAOOu8d5PVOCYcNyR+06y3g2Ez5nEUN/l1
         qKKw==
X-Gm-Message-State: APjAAAUvMzmW1CMS+YxYzKb0rQ2NKfGgj+Zyf3KgJIaq+qkUun/PUQfJ
	moIOuzl87pB+7x4J9aeyJxoVnEEgwEQU0QPTsBOHGXhmeDBZaQLSmKJgd9xaiVPuBYJN72Gt8jr
	79+AcZ8c3Njp6ORgHKbyqcEajL0WMU/llkQJUxh9/DI0ztk3J5B6U3MaSd62j2P8iwA==
X-Received: by 2002:a02:2e52:: with SMTP id u18mr15349887jae.84.1559787590644;
        Wed, 05 Jun 2019 19:19:50 -0700 (PDT)
X-Received: by 2002:a02:2e52:: with SMTP id u18mr15349851jae.84.1559787589997;
        Wed, 05 Jun 2019 19:19:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559787589; cv=none;
        d=google.com; s=arc-20160816;
        b=Sj0bZA5MKtj6ArP7iaHK6DDWQVpO0CDRwXAgvcML1BiybXSSvqA9TcLuHaZI+epjuf
         Hz8m4LW+LT4QB1aSGWkUN0LSJqQ6fV0iLG6qIBM5uKEj/sOdOo5rUY5ZQgZLeKbErpkb
         jhscrFDMbtAOJIqmFFQLALZnTKv7zdq1xhETBG1eHDmRAYqSSpZGfHm9leBdN981LYbG
         eGfCsGpGu0NllRIW6fGYZdTSsoAXEWsuV22T3MI/NUZYdOboh2j6swvosUN23jZg5KgY
         uxBh8tptJMzXbbBcpjhPyM18PmVSb1199e5rq1hUVUyNo2G9sdzto85YHQ4fBopmwwBx
         EjDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DTWH24yA/1C8wqtT9jqxaOXK4VdWlElUekSQr6wCUNk=;
        b=X9NspZkeYVye6DOlR0y8SVxNXh4ZQrfB36cdJZlk+/lHQPW0FdgLMD9ty3JJHKMVJi
         XHeoOJnrTTJsTicqMl4agG+Vvdu/BlK1u+k0jeF6RJkJNmoXpIhCtO5Vvne0C+XqiB2v
         XDBO+bKZmj9KOZJCVaqrP/D0Zy+n7AnlumNMm7P2N947781lDEO7KyEe5/QtQJv4l5Cq
         UHZOJyJQ2esSDxPJ/Z8+ByuyIS0IKcI/lg9OXwUKozyqkwe3VLQANU8xTZa4rXmhFiX1
         RAgzqpDCVIA634gtN1eK1dyKv+XK78kXi3vrNF48GX95BVih8bSGcYGU3y+ZToVhGA+b
         2aMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kmgXYItR;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor291799ioj.120.2019.06.05.19.19.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 19:19:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kmgXYItR;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DTWH24yA/1C8wqtT9jqxaOXK4VdWlElUekSQr6wCUNk=;
        b=kmgXYItRTWz7KU83m4f4kQdWt8EQlqNIcHOHwnh10wNa68tCz1p6bokonrDgngqEr+
         FRMLMaIy/lj5RAYS2Z0jJjnURXbh17DPBk341t6COKHH3QlsLfEvtoqXP1NllVRwEicd
         1SsU9xldKIqlRNVu1j1kw49OJgqIolMCZuxAzit5j6NdewERw7I9rjzHfEFc8Lk8ntwd
         XI1GCa7jtok3tNC+8zLVW7bL2tYjpPP1Md3foyuun58BQ32SuG+j0DtX8LC5sVbYHAdL
         p4VPKF4pCtFpj9AQ8swn3mpHQ2Ka0oQpGEeWUHC4RfvzPbvsg7Hioj3HcfIul55kE4sU
         XWTg==
X-Google-Smtp-Source: APXvYqx6tx6RmC3nwgq5oU/5SMi9/vNBFMonltoudZNJjPfSzLhIZd2vSB8s2xPe4+DAhUve/ybsToT4hpYWtZchLEw=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr15331128iob.15.1559787589673;
 Wed, 05 Jun 2019 19:19:49 -0700 (PDT)
MIME-Version: 1.0
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com> <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
In-Reply-To: <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 6 Jun 2019 10:19:38 +0800
Message-ID: <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Matthew Wilcox <willy@infradead.org>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 5:49 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed,  5 Jun 2019 17:10:19 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:
>
> > As for FOLL_LONGTERM, it is checked in the slow path
> > __gup_longterm_unlocked(). But it is not checked in the fast path, which
> > means a possible leak of CMA page to longterm pinned requirement through
> > this crack.
> >
> > Place a check in the fast path.
>
> I'm not actually seeing a description (in either the existing code or
> this changelog or patch) an explanation of *why* we wish to exclude CMA
> pages from longterm pinning.
>
What about a short description like this:
FOLL_LONGTERM suggests a pin which is going to be given to hardware
and can't move. It would truncate CMA permanently and should be
excluded.

> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
> >       return ret;
> >  }
> >
> > +#ifdef CONFIG_CMA
> > +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> > +{
> > +     int i;
> > +
> > +     for (i = 0; i < nr_pinned; i++)
> > +             if (is_migrate_cma_page(pages[i])) {
> > +                     put_user_pages(pages + i, nr_pinned - i);
> > +                     return i;
> > +             }
> > +
> > +     return nr_pinned;
> > +}
>
> There's no point in inlining this.
OK, will drop it in V4.

>
> The code seems inefficient.  If it encounters a single CMA page it can
> end up discarding a possibly significant number of non-CMA pages.  I
The trick is the page is not be discarded, in fact, they are still be
referrenced by pte. We just leave the slow path to pick up the non-CMA
pages again.

> guess that doesn't matter much, as get_user_pages(FOLL_LONGTERM) is
> rare.  But could we avoid this (and the second pass across pages[]) by
> checking for a CMA page within gup_pte_range()?
It will spread the same logic to hugetlb pte and normal pte. And no
improvement in performance due to slow path. So I think maybe it is
not worth.

>
> > +#else
> > +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> > +{
> > +     return nr_pinned;
> > +}
> > +#endif
> > +
> >  /**
> >   * get_user_pages_fast() - pin user pages in memory
> >   * @start:   starting user address
> > @@ -2236,6 +2256,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> >               ret = nr;
> >       }
> >
> > +     if (unlikely(gup_flags & FOLL_LONGTERM) && nr)
> > +             nr = reject_cma_pages(nr, pages);
> > +
>
> This would be a suitable place to add a comment explaining why we're
> doing this...
Would add one comment "FOLL_LONGTERM suggests a pin given to hardware
and rarely returned."

Thanks for your kind review.

Regards,
  Pingfan

