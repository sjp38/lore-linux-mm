Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA5DFC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:25:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A846222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:25:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="V5yd8V+M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A846222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89A08E0002; Wed, 13 Feb 2019 08:25:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B38058E0001; Wed, 13 Feb 2019 08:25:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A277A8E0002; Wed, 13 Feb 2019 08:25:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6312C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:25:18 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p20so1670184plr.22
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:25:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JDK7YwyTGvm7x2Sf6x4F2/57uwwOVD7bIycRuQRv664=;
        b=G70LZRNyF6D5DnjdsW80xeqJTG7Q+K30FvNRK2yeZGv30nlL+C81YkqGmmmQrn7Lyj
         k7NkUBoWb+ubrlH8xwIfngeh/kjyfeMzxBvtQItDQxMDgs4necQBrwk+cjzAwJ6oGXtJ
         AWqjlepBWrc+CiqmC4nnC5XuvTAUFj781n6rRpYMeaF4BUCfYGiGEZmCPIngWPrUcHEZ
         be1C19mkqjBarRM8oG1FFB9wjaXmvqQPiaCwHAh2p3664/X+/AhpwMSgC1Xr+fuASlFz
         oiUm/InIPds4X3Twkf8h2FXdnGFglO5FSFcQOMfdYp6qxzL5nYsFnU+QG9zjJUMDRK7j
         8gqw==
X-Gm-Message-State: AHQUAuaKymQ/l5MbRyBdEdI+ecEz9WvUGmn2zz8IsiDOBLL6k/gdXHYz
	V5Xf6a4jebg46aQcThudV0t3PNhQCVBb/oh1xH7WJ5owykQZJjDMmMyBnswfVEBOC49XRi9l/k8
	8c1rrfPqtdDCzz0C6HR7t7GgpVbWlFVsk41lzQktOqGUv7jfbks7jiOtMUCCdDAWzf3dOZejgxE
	o/Q4TDxkQUyfONQBq3eSxLk9XVPSqLKjF8pRPGN6IZnzlKm9JNsDN3m6RxPywkzpQTgco/+UTCF
	DBgUv1geGiSxeJvvWDY5LeNwZm/WOFMH1nWWOyVCzJdLziVLEQgdsuJkaVwGuxAYsNnO+fy116B
	p7YUFvUvpXuAfzIr6xLZ7OUKzLlZ9yL4+bTEo6ToBPew1QjOpS986fyuYzbJMKvuJsbSwhZmxyK
	A
X-Received: by 2002:a63:2c8a:: with SMTP id s132mr476994pgs.440.1550064318059;
        Wed, 13 Feb 2019 05:25:18 -0800 (PST)
X-Received: by 2002:a63:2c8a:: with SMTP id s132mr476922pgs.440.1550064317046;
        Wed, 13 Feb 2019 05:25:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064317; cv=none;
        d=google.com; s=arc-20160816;
        b=MIBlTTs2ZfHtc6GtiRNklo1RmFTItnjWYCJ1D/zNsHgvU0mjNEfw/wqQc7yYNZmcuT
         HaC70ata+dmFot6Ii0n3kqsvsjFVoZNzHL2OuByXe8qAazM87ZrtOBNrsbV7/7A5SHzA
         9XXdm6Y6d/iviw7dW27iBhjEqB6d/8whhCWUrKRCC6ger2j2p9b6T5DhATdULQ4OKLHW
         Sd7AWMea2XlTJuycP0SkI7LlBh8h78xdW+/Zf2Dx0UiEUp8kwZazqVkN9vqwa6F1VfIq
         yDGoRQiy+q2evGGr/YAP+chfyszBJb7FbF+Xp0oQ9m//6ZR1pXzpUeqSO1jCvFEVMDkG
         167g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JDK7YwyTGvm7x2Sf6x4F2/57uwwOVD7bIycRuQRv664=;
        b=x2zEuJvMi9uaCkd8VPzDvTBP7CaH2FdnRCM+0A0tD5R1Nv+9s9jNAFMmQ6/LZ3WFtR
         u10i/OqimE/u6tN9Gjafmhrl7y7i1S7Z+bE/xpqYKM6q/UMsugN2b8EpcfTnc4Zbs4VU
         5Bk/UhyZrkTHmj8OoTJUqTCy9qy1m8ZkXdP1SLq7L0rr5PDRAydGOyqU71NeRV1wMk7H
         7ocrt9slTNNWXtR3abYlrPYFTZWQNmRVokNm8TbucB9wDqDlO2HvhfyXIzZEpmvONZVg
         UUgHMJxbrg7opV63a96Om0XtmiKJX4jiqprBF/8FC6iRxM167ssI+roT6wJYtIsjlzWs
         Tf9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V5yd8V+M;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor10926838pgt.24.2019.02.13.05.25.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:25:17 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V5yd8V+M;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JDK7YwyTGvm7x2Sf6x4F2/57uwwOVD7bIycRuQRv664=;
        b=V5yd8V+ME+qqPIPRw62h4cwOcfdUd5S/SMCyHZZZJ7wzzeT+hVGG9NsWLr7RCznsvt
         69LyHk09hzKG99Sph9lsF/IV2zO9i7mI4p2qb0nqOQJor/3lWgPnXjP1us9rRlBwunny
         F+XdU0x9jIhlrL+P0edFScfXEXJUNwCeSvnQEOVhfx8SkCC1uippRacLaY8r6Gl889ad
         Qk0bgTagJUPYeaSaWEMbHIUpScvpTrHUWa99gkcbyEUXNXjyThfnM/MDcPHqzHG1/Vaq
         /jheFVPZO5OUVchkWhLJNR2VWRAzE2mi6DkhYZh1xbGoS1wUloom+KoxU+KZIe/2HDRn
         qFRQ==
X-Google-Smtp-Source: AHgI3IZl5WKJdwVCrLY/jCZlAXw9WcZHiK+bS8GVGZgn/xiEjhxBOuxWiqqBVu0nsKSlr5uE4c9rfpS9B3hoaerx9Z0=
X-Received: by 2002:a63:7f46:: with SMTP id p6mr512867pgn.54.1550064316418;
 Wed, 13 Feb 2019 05:25:16 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549921721.git.andreyknvl@google.com> <cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com>
 <20190212131250.0f98d6a9cea8e03ca47f980c@linux-foundation.org>
In-Reply-To: <20190212131250.0f98d6a9cea8e03ca47f980c@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 13 Feb 2019 14:25:05 +0100
Message-ID: <CAAeHK+w3r9nYwesNYGjbcVwZj2ceTeNaVq0pD7SnLRLb7PiWtQ@mail.gmail.com>
Subject: Re: [PATCH 4/5] kasan, slub: move kasan_poison_slab hook before page_address
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Qian Cai <cai@lca.pw>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:12 PM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Mon, 11 Feb 2019 22:59:53 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > With tag based KASAN page_address() looks at the page flags to see
> > whether the resulting pointer needs to have a tag set. Since we don't
> > want to set a tag when page_address() is called on SLAB pages, we call
> > page_kasan_tag_reset() in kasan_poison_slab(). However in allocate_slab()
> > page_address() is called before kasan_poison_slab(). Fix it by changing
> > the order.
> >
> > ...
> >
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1642,12 +1642,15 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >       if (page_is_pfmemalloc(page))
> >               SetPageSlabPfmemalloc(page);
> >
> > +     kasan_poison_slab(page);
> > +
> >       start = page_address(page);
> >
> > -     if (unlikely(s->flags & SLAB_POISON))
> > +     if (unlikely(s->flags & SLAB_POISON)) {
> > +             metadata_access_enable();
> >               memset(start, POISON_INUSE, PAGE_SIZE << order);
> > -
> > -     kasan_poison_slab(page);
> > +             metadata_access_disable();
> > +     }
> >
> >       shuffle = shuffle_freelist(s, page);
>
> This doesn't compile when CONFIG_SLUB_DEBUG=n.  Please review carefully:

Sorry, missed this. I think it makes more sense to move this memset
into another function CONFIG_SLUB_DEBUG ifdef, since all other
poisoning code is also there. I'll send a v2.

>
> --- a/mm/slub.c~kasan-slub-move-kasan_poison_slab-hook-before-page_address-fix
> +++ a/mm/slub.c
> @@ -1357,6 +1357,14 @@ slab_flags_t kmem_cache_flags(unsigned i
>
>  #define disable_higher_order_debug 0
>
> +static inline void metadata_access_enable(void)
> +{
> +}
> +
> +static inline void metadata_access_disable(void)
> +{
> +}
> +
>  static inline unsigned long slabs_node(struct kmem_cache *s, int node)
>                                                         { return 0; }
>  static inline unsigned long node_nr_slabs(struct kmem_cache_node *n)
> _
>

