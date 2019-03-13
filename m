Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F164C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:18:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B862171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:18:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NcmTjTnP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B862171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDA718E0019; Wed, 13 Mar 2019 15:18:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB2698E0001; Wed, 13 Mar 2019 15:18:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA0518E0019; Wed, 13 Mar 2019 15:18:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5328E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:18:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so3203693pfj.19
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:18:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FWhPJ3WNEGAzoi65eJxiwmXgvhDwWzZG2Rd8Px4UT/M=;
        b=M/tC4q1In5rWBBYKhP+T05Y2tCsjyWFjDPm5Yg4RmlA4Z/sPGf5oNecSQr0XYuJURh
         sannrj+vLut5Zj+I3P0AatEPckRrl44pA3PDiJaFhzr9CEHtbr4VnaZpM1yiE9kwVGoA
         +ci30tuXm80SkVytsCwSvk7TW/znia74R9alTmSEWvnfEHaomD4ucEmseGcOwn36/Vb8
         G6vJ3ecGawPdqsOgt0wzql2aJVOWIRWfBHoEhC6iyaWhhxWxwKuF9/dwUtVyQzjQdcF2
         ZZPbpB61eljoClW50VDx1+juCoJkmUJSpLATaSO81i4vc5a5oJncm90aX1UmGeh2Hagh
         lJ5A==
X-Gm-Message-State: APjAAAUFyib8W1GIxndD1svuJEBb6VOOOh9AY9wFQavuocbEDRzUH76s
	kCtptRRuTdfzS36t6iVjZPTgOu8tiqg4dO0PK+Re0KSvExNtkEOa+uD07XgcwGRp/R9C8YSSxfJ
	LSx+Uld2Hc+LCCChJQEOkOxkC/izssPyeqzVqM2p5MtCsBr18jvp8kjeCqibcy7EgvJxVLtvMWq
	Qg0Sem/pRwjGb/KT7Zr+fnnKSDOLq5n3jj0FUE6Kv98Gf1hsz+hbOKR7cOEYHujg4qIVPpNK2i5
	ooR0cEmilVcyK0aVWouM1rc9Qg9S59onACT1BrGciZ+FMp8CMZC51w7JTrqbl+MmFXS3rfO5uJY
	8fMwwObwyF/bwnZX/DX+sJgKg96B8DblLWLX6Ook5NBN1qf6u7NDNYDqJV0OjgxUAoCI0dG93DW
	W
X-Received: by 2002:a63:e447:: with SMTP id i7mr41362166pgk.70.1552504717308;
        Wed, 13 Mar 2019 12:18:37 -0700 (PDT)
X-Received: by 2002:a63:e447:: with SMTP id i7mr41362098pgk.70.1552504716441;
        Wed, 13 Mar 2019 12:18:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504716; cv=none;
        d=google.com; s=arc-20160816;
        b=nZg9PAWMtD12NGAjo4lSauj6tMzQYfvBRpP635LkRbcZ87M+F98tetUMkNfWYQEDpn
         9oZkCUIXSuWkrMk6EZiDHyU2RyYvuwcTHa4HfMcvyi+v4eJwNQPNp629aJXM2fkJ75Zu
         AFILVzMcHT0X7JBqbtCvw8U/+vdLVFd7SSKwFxR+opgIyMVZcMv9anLjl2IkXMGcVvn5
         WGuDryew5EoOESdSDTw18Fp+2U3rX6GJgkdT9Rf9AREnRgVfDLGoYQHu9pv/eVRjPoWn
         5eYEe84FSPd/0B0oBz2ASu2IZB8gdtYJexZxbFFikyTK6IM/azuvMKQpWZ/aix679SRv
         JzdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FWhPJ3WNEGAzoi65eJxiwmXgvhDwWzZG2Rd8Px4UT/M=;
        b=qBmEpCRD14QKJexI8sw0cGKgI0yH3/uQ9pkYND2oY2CfNTKKurKaQWlZGEY7/K3iUJ
         Olf3QLsftH9v6qQd95vv4iztDcKOJlcpRamiKl5sNgPPIF43y4ud8KA1CuxCAFUopK9f
         2ZVakQqLeAceQVU5JKpPNJn95AlYvETrqI1x0CeJwHIIiJqg7RinOlunq7mLuJgg3yjC
         0hf527gKrc5EfS7THsVo0v9acVtkkOcr06U+DLxnfFWh/0folwAi8LB5CD/VimRyQKLZ
         m6gL/IM70e51WR/2EFKUPl7CJ8ZOp7/foemGW62ID5cyA4jI8vUaSAYUS/BV3nTfpcC5
         mrSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NcmTjTnP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor18962742pgm.47.2019.03.13.12.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 12:18:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NcmTjTnP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FWhPJ3WNEGAzoi65eJxiwmXgvhDwWzZG2Rd8Px4UT/M=;
        b=NcmTjTnP669KpQSaJDsEVbwa7ZSzy7RTfIIe13UmBh3jYlwMYcna5tYe4UPD7K0QWp
         FIrtHvkbkTM8ZBWJ3XThzGI16NdwnR8y7gi2UQUoklv18NqvNlv4dUVkMLbgqH27ruof
         dMtQcwagO8GS1fAZKEB8X4sTCzzPxWzs+1gOQVLVU38G4SmKQ1h6nrViaEOFgwalljeG
         55Bjh7XKlWG2CJ+yxYisD8n8CKG6RRXlonBc96iYd7oScLW/Vq1waoOB7NOdC6jSE6/W
         zzdnOCFfi4SnFgQd4EK3xcv0kGMPk3W5KRAEg09Ml/WZwYTy1iA0HnD/paLeGOZvXgsF
         GzRA==
X-Google-Smtp-Source: APXvYqyhqJNYym2YNvO7ZRCVAOdtXq1+cu5eY/wmttmIdLIRskcfobIWUY0/oQcJh6Qub3CfDQ7R1ZoFLvgFmhtTDG0=
X-Received: by 2002:a65:6651:: with SMTP id z17mr39579463pgv.95.1552504715765;
 Wed, 13 Mar 2019 12:18:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190313191506.159677-1-sashal@kernel.org> <20190313191506.159677-22-sashal@kernel.org>
In-Reply-To: <20190313191506.159677-22-sashal@kernel.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 13 Mar 2019 20:18:24 +0100
Message-ID: <CAAeHK+xMxX3Baou=W914tbbPhuPGCBd4wJdgS3O459JEwxw5OQ@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 22/33] kasan, slab: make freelist stored
 without tags
To: Sasha Levin <sashal@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, 
	Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Kostya Serebryany <kcc@google.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 8:16 PM Sasha Levin <sashal@kernel.org> wrote:
>
> From: Andrey Konovalov <andreyknvl@google.com>
>
> [ Upstream commit 51dedad06b5f6c3eea7ec1069631b1ef7796912a ]

Hi Sasha,

None of the 4.9, 4.14, 4.19 or 4.20 have tag-based KASAN, so
backporting these 3 KASAN related patches doesn't make much sense.

Thanks!


>
> Similarly to "kasan, slub: move kasan_poison_slab hook before
> page_address", move kasan_poison_slab() before alloc_slabmgmt(), which
> calls page_address(), to make page_address() return value to be
> non-tagged.  This, combined with calling kasan_reset_tag() for off-slab
> slab management object, leads to freelist being stored non-tagged.
>
> Link: http://lkml.kernel.org/r/dfb53b44a4d00de3879a05a9f04c1f55e584f7a1.1550602886.git.andreyknvl@google.com
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Qian Cai <cai@lca.pw>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Evgeniy Stepanov <eugenis@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <sashal@kernel.org>
> ---
>  mm/slab.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 409631e49295..766043dd3f8e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2378,6 +2378,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
>                 /* Slab management obj is off-slab. */
>                 freelist = kmem_cache_alloc_node(cachep->freelist_cache,
>                                               local_flags, nodeid);
> +               freelist = kasan_reset_tag(freelist);
>                 if (!freelist)
>                         return NULL;
>         } else {
> @@ -2690,6 +2691,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
>
>         offset *= cachep->colour_off;
>
> +       /*
> +        * Call kasan_poison_slab() before calling alloc_slabmgmt(), so
> +        * page_address() in the latter returns a non-tagged pointer,
> +        * as it should be for slab pages.
> +        */
> +       kasan_poison_slab(page);
> +
>         /* Get slab management. */
>         freelist = alloc_slabmgmt(cachep, page, offset,
>                         local_flags & ~GFP_CONSTRAINT_MASK, page_node);
> @@ -2698,7 +2706,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
>
>         slab_map_pages(cachep, page, freelist);
>
> -       kasan_poison_slab(page);
>         cache_init_objs(cachep, page);
>
>         if (gfpflags_allow_blocking(local_flags))
> --
> 2.19.1
>

