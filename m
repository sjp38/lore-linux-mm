Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 893F5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:27:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 445A7222D6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:27:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="A11XKqcF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 445A7222D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D40788E0005; Wed, 13 Feb 2019 19:27:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D17508E0001; Wed, 13 Feb 2019 19:27:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2F788E0005; Wed, 13 Feb 2019 19:27:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8280C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:27:21 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id j32so2948100pgm.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:27:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nMnhjtqVdgPByvYYJJCyKk7KktNyY4yGIyHkhdv1Ego=;
        b=ujeHXobhJSkrd8IUfM8BlBAZhvWp3p59cpK8mRaG+uZ1uabPtNPYsY3hAV2waqnCZ7
         oCsf8WP68TD99v7ApCcqS3NrRF407u5Dk35cEERt/VGdl2W68uLv4FPuwfmrrGQhstLR
         55kEaXkWiSmlEOy+QT9Yyzrc3EDOFL8VIZDHLSd27Ylzaf0Sbw7aYs6kAfPRDLLi6WFu
         y/AOzoa1ZgmUa2EHijF/y4FnGW5Zs1buQo7+nXvEjszp29R9wPPg4/cCvdyJbMVCQu5r
         x4BJJSGl0eG5l6Kcn3ePKcZNuY8bA1aAyImA5tgRZ3jEDiuOPKoBPgHpCXdfITyE9kJa
         Q3Vg==
X-Gm-Message-State: AHQUAuagWn9UCDG2hJIRbDY952/7ZoOFxs2JCy/admKpuAHNlQc6v7q8
	dKAz706l5pCsQA9w2Ww7hmgQBOaPBVTMOdg+Sq4+JqCtN3l1vxQt2APOVMBBHokA5/Ali8CrMY/
	3yi/WyMw2f3HkXhp4gzVSwOSqF2msuyThUEsMmxD/9xA+4t5KgEw4+rKr+WeGquL1kMJy7HZS2y
	S1SsL21G5zoFYpj4YTjRqKyPTt4hI/n36roJK/GFgbVUSrSs8CmPdWUr9j5OqzoKdUuLt86uL5v
	2ZpXZvOOrFlu5iK06QYW4xUViNIGcLXxx6zwur55PRruwPxxcf/yNCY14I2yalulqelH6HUpi94
	4K9eoRSEglD7t1BcKiOshrMGzLrqrUtNdzwFQrlj4MhbK+xmx8nIJI+8vBmT3Rs4mYRZYXWZLsm
	Q
X-Received: by 2002:a63:ea06:: with SMTP id c6mr959341pgi.162.1550104041209;
        Wed, 13 Feb 2019 16:27:21 -0800 (PST)
X-Received: by 2002:a63:ea06:: with SMTP id c6mr959284pgi.162.1550104040421;
        Wed, 13 Feb 2019 16:27:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550104040; cv=none;
        d=google.com; s=arc-20160816;
        b=RBWsOqqkVKr/VXjO4cF7hUh/Qtpx4j6Pbymf1pVDe18CJ7/Cwt6loA8Tm4sIU7CG2i
         cZ7IL0+/K75Q2e5vdvKauoKWXZLjpW88E9hux2OqMjXv+kI+oZgZO7fX+er9bGK6DEIg
         Re+7YkXCWdl+lFFM2ZoRq8IaB0P40hG4U3Tk/CSFE5VLvb+pBi7WgjKesWo0fVcemwpM
         Slo19J2MJdfitCVFCAeX+F3lln+P36oTOcrs4+I8CH6G2f10yce2TrLnBatUqZCzgkpz
         rgFcykfM0eLdyTuvZHN4UMm2ZP86aqf893J1EK6Zs+8cqhgwYasVoJp8HlScPDqMhbDx
         uLyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nMnhjtqVdgPByvYYJJCyKk7KktNyY4yGIyHkhdv1Ego=;
        b=vgI9ISGgVw+nXO7Zv0qFN3RFd0RV5xZHhknw/qjR0mFBkSqYZhPflbDe2r6O4xEj0Y
         cvf5ILI4yf6e1luWVAJ7xkyu0YkiL9E4QMjNmhhY0HA+tcgyqVkDYI+6N39zO3W4TSDL
         jAxxFcLJCHIZxTlonYqXGJg3AJus7TshJ9l3qmRHGz6AXu4+v/9gv/iiHNZI35QbUIgd
         28wLHH2ZZVC9x0AIzfJPSftv7bg0xZ9NZs0ZRKkDXKE8P/jE8zNuVpuz6bHhZDGSu7pr
         aTSVf3T/0yEvongb50d1WDzRl0RaAw7EbLHNiLgHcxfi42UvHdd6KcCJm+adXnqwyaHG
         gHeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A11XKqcF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j22sor1193685pll.8.2019.02.13.16.27.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 16:27:20 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A11XKqcF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nMnhjtqVdgPByvYYJJCyKk7KktNyY4yGIyHkhdv1Ego=;
        b=A11XKqcFo9JTB+aFSaL/DgcHLfl2LOj4ZBNO5OvcDFJr5StoLjT/z9pdRp1l1CVHrV
         IosQcHhDGwA7ScUxVsB2wfAjAiE4hRNwTa84AqaL+j8FFuVC9NvNTfjuCSAMlMH52RfL
         5xuiD4Sab8kDTVkwx9P4+8ebN4dmWs/ZII6BWiHXaaGP2H99Abjt3A8sMx06WsBjDvdI
         zQHBDs1lU5o1XWpNUwuYL9BrkZpdKk7pgCFVeN+iI8nLJDP7n3+/ztaeLZMcyUp7o8PF
         0lrg/QlOLS7GMibEXFocwWTBQbPMXYr+Riznm9AW8AISXOdn1ch+6b5VQTKwVhRt9yXQ
         BslQ==
X-Google-Smtp-Source: AHgI3IbYhBZZTUaRoFQmz74HXKjqlvRInirhBE9dP3FgmdmkPFbfB1XUwZIpVL9JhPO7DFOgaK/qlXy8SH/KpEzuK7o=
X-Received: by 2002:a17:902:1122:: with SMTP id d31mr1041683pla.246.1550104039964;
 Wed, 13 Feb 2019 16:27:19 -0800 (PST)
MIME-Version: 1.0
References: <bf858f26ef32eb7bd24c665755b3aee4bc58d0e4.1550103861.git.andreyknvl@google.com>
In-Reply-To: <bf858f26ef32eb7bd24c665755b3aee4bc58d0e4.1550103861.git.andreyknvl@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 14 Feb 2019 01:27:09 +0100
Message-ID: <CAAeHK+z=ft93RNx7rvq1QFr3kiOFVzBVACEFN4fL8nbEVOEXKA@mail.gmail.com>
Subject: Re: [PATCH] kasan, slub: fix more conflicts with CONFIG_SLAB_FREELIST_HARDENED
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Qian Cai <cai@lca.pw>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 1:25 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> When CONFIG_KASAN_SW_TAGS is enabled, ptr_addr might be tagged.
> Normally, this doesn't cause any issues, as both set_freepointer()
> and get_freepointer() are called with a pointer with the same tag.
> However, there are some issues with CONFIG_SLUB_DEBUG code. For
> example, when __free_slub() iterates over objects in a cache, it
> passes untagged pointers to check_object(). check_object() in turns
> calls get_freepointer() with an untagged pointer, which causes the
> freepointer to be restored incorrectly.
>
> Add kasan_reset_tag to freelist_ptr(). Also add a detailed comment.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reported-by: Qian Cai <cai@lca.pw>

> ---
>  mm/slub.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 80da3a40b74d..c80e6699357c 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -249,7 +249,18 @@ static inline void *freelist_ptr(const struct kmem_cache *s, void *ptr,
>                                  unsigned long ptr_addr)
>  {
>  #ifdef CONFIG_SLAB_FREELIST_HARDENED
> -       return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);
> +       /*
> +        * When CONFIG_KASAN_SW_TAGS is enabled, ptr_addr might be tagged.
> +        * Normally, this doesn't cause any issues, as both set_freepointer()
> +        * and get_freepointer() are called with a pointer with the same tag.
> +        * However, there are some issues with CONFIG_SLUB_DEBUG code. For
> +        * example, when __free_slub() iterates over objects in a cache, it
> +        * passes untagged pointers to check_object(). check_object() in turns
> +        * calls get_freepointer() with an untagged pointer, which causes the
> +        * freepointer to be restored incorrectly.
> +        */
> +       return (void *)((unsigned long)ptr ^ s->random ^
> +                       (unsigned long)kasan_reset_tag((void *)ptr_addr));
>  #else
>         return ptr;
>  #endif
> --
> 2.20.1.791.gb4d0f1c61a-goog
>

