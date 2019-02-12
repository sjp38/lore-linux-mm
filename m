Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72565C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DCCD2084E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="geSm948Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DCCD2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B03778E0013; Tue, 12 Feb 2019 08:27:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB3428E0011; Tue, 12 Feb 2019 08:27:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A1E18E0013; Tue, 12 Feb 2019 08:27:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2E18E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:27:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so2123607pgm.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:27:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6Ba4mrnZaxTMVtD2bbYgpygn35lrgkquNjMLSonGxrw=;
        b=eGzBrnoauC5UcL5a3WPjvLqwZ/dchuWOpZUQ7D36vmykjLS+Mzw66RLXer4rDhggXB
         J9i+hQiJSv+4jvjDbmPdwMAOc31FRKWtBpJNB6H+9OXRfg8t+1QXKzKv4Yux3g2dDFqA
         w1ok2cFRH67CmfYamSjcVv4Q5di/D68fSHe1GhlqKtpvfjhA/KyJ6GLVJaTI9aIS1R7c
         momlhybcehxuws0wbhSG/aca6Eoj4x+25DMDSNBscI86jNA9U3LMJUNHlpIvER8Mb6WF
         r/qxJPLm6SUg7j0ave1AYxVHYUeSENgjVwsC5IEahNCslwXuA/PxlL3uJN9FQMF6aKZV
         E+0w==
X-Gm-Message-State: AHQUAuYpkJQ3Qm3M46KnXCGNNk8w/AVnn1A2W8sSR9dVwBtY3u+jIB60
	v4L6kObPw4AhQkQjqrhaXdGHqkTPeU/RbqgjmTESnxwJ/jeAAoCeNE6JAAMX6xMqdkYExan/Rkg
	4JmeZtDJRbtLMEBdxJ+ibbmnv/sScZIs0uQTUifOYRedo7l/XJenqnPelT2bRxNtXuXRSmthCjn
	XqfTM/ELgwm2C7dSKstwlREA0c++y2CjkaIvld+hnooKT3x8zVGW9Ehroo2mZW7m5DAktyPHD2Q
	oSZS3tJztwpGrk3wX8ssOkogaD2Spctj1lCUv5u9hKsUe60iUoF+M8+8POiOAq7ATz5hr4VYmId
	BsBSBRGtEqvk9GDlcBH1Ol+J0VQrgLtXVxcNFb9YQPiY5IFEPA2UxpyrSbcfB3ChvsNHuOUuDIN
	H
X-Received: by 2002:a63:3206:: with SMTP id y6mr3615278pgy.338.1549978030922;
        Tue, 12 Feb 2019 05:27:10 -0800 (PST)
X-Received: by 2002:a63:3206:: with SMTP id y6mr3615223pgy.338.1549978029971;
        Tue, 12 Feb 2019 05:27:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549978029; cv=none;
        d=google.com; s=arc-20160816;
        b=fXrU2rK6wgwC3rAzUw4h80cysF5T5U47n9PLoI+voUVi8FexiBokOW7ZRBDDHeEPKX
         e5njOX7aD3BoDMXD17v0x5CUXdclaMKUtmSM/sXUlbsNperAEv+Uo32+qaFHSjWuRI2u
         yFd54lh6gmB580s2lhYvEeWdK9uNubpif6Z1g/tnuPLDaCQqprRMbPx9WNppbbsQ33/i
         wg7FM8f0KvoSxLJoYeuqJfIQe9KVzshW5pgj4fxG0EA2nDMDrRAD6kSi+ZEODjNYdRFG
         29Wqx5fmBTB/jRP5JR6T2FNywT01822usUrJ5t5Ho0XoPRBSSkkj22HWj5iaJlrFwd3v
         i0lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6Ba4mrnZaxTMVtD2bbYgpygn35lrgkquNjMLSonGxrw=;
        b=Wz/ZgTwT6guteS4AdfG4k9a+1Tctm+40tJMXAihCReaDcy1rmyefgk6oZyyv4ZZY1i
         /VVWvXIp63lriR4NN6yZDYuqoC6iO+HefF8MXmVQTU133i6l4dM2EASQlJqqWuq/ma9N
         hw1+etCQsvpkqDuw0zdU35V+3Qqd2JTIVkGGR7AKk81fBK6x5bp5abdrbNBFd5qdwGTg
         DBq5NccVh3KxxvpGUOZn2bEivlOifpYg9k+5xw4iJ4t2uQTPLvLxjY4qAutMpklFFzmd
         sSzYH+l5TrZufwFdMr/6p7JRYMMQ3SWTjLpSzlMOomEDJYUYvXZWwSLBtHiLmNKiCFDl
         V1Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=geSm948Z;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w34sor11770513pla.10.2019.02.12.05.27.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 05:27:09 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=geSm948Z;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6Ba4mrnZaxTMVtD2bbYgpygn35lrgkquNjMLSonGxrw=;
        b=geSm948ZjGKpmp4A1fg6RPbdILSvX/YQikGKf69neRzarLTs2iM2U9H/AQbb7yNrgo
         8TOSDM1FYoACO2R79Dubem7OmophgcsyhbMcEDGBpZobfHY4shtc5JyTijlPoek6IPAL
         fXOq61HHT140SAU3wFO8+T3foQGYlOUE2KNGY7gjVvrjIWNUIYfie7XUuaSkO+L4CwJ1
         yCz/s110r60L3lKv09SsZAY9+DSagzxzYGt5OLyhYw9/fEBzP0CAuiDuF9oNt2sdrxFt
         5xpj2E1gc2leHmV3C6AKGidy1gkIBHrjl/yFogSvCNFHIF94pKmO83OgRTwW2HDqP3GF
         SLUA==
X-Google-Smtp-Source: AHgI3IaEXSCnkXFUgips13819VMT23YRSgARmZJjD+u4ORQfzwT9CoVffDanWSaZ1PGwGgUrMuCxw0jw36wHEEOVfig=
X-Received: by 2002:a17:902:8641:: with SMTP id y1mr4016029plt.159.1549978029254;
 Tue, 12 Feb 2019 05:27:09 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549921721.git.andreyknvl@google.com> <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
 <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
In-Reply-To: <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 12 Feb 2019 14:26:58 +0100
Message-ID: <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED
To: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 3:43 AM Qian Cai <cai@lca.pw> wrote:
>
>
>
> On 2/11/19 4:59 PM, Andrey Konovalov wrote:
> > CONFIG_SLAB_FREELIST_HARDENED hashes freelist pointer with the address
> > of the object where the pointer gets stored. With tag based KASAN we don't
> > account for that when building freelist, as we call set_freepointer() with
> > the first argument untagged. This patch changes the code to properly
> > propagate tags throughout the loop.
> >
> > Reported-by: Qian Cai <cai@lca.pw>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  mm/slub.c | 20 +++++++-------------
> >  1 file changed, 7 insertions(+), 13 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index ce874a5c9ee7..0d32f8d30752 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -303,11 +303,6 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
> >               __p < (__addr) + (__objects) * (__s)->size; \
> >               __p += (__s)->size)
> >
> > -#define for_each_object_idx(__p, __idx, __s, __addr, __objects) \
> > -     for (__p = fixup_red_left(__s, __addr), __idx = 1; \
> > -             __idx <= __objects; \
> > -             __p += (__s)->size, __idx++)
> > -
> >  /* Determine object index from a given position */
> >  static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
> >  {
> > @@ -1655,17 +1650,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >       shuffle = shuffle_freelist(s, page);
> >
> >       if (!shuffle) {
> > -             for_each_object_idx(p, idx, s, start, page->objects) {
> > -                     if (likely(idx < page->objects)) {
> > -                             next = p + s->size;
> > -                             next = setup_object(s, page, next);
> > -                             set_freepointer(s, p, next);
> > -                     } else
> > -                             set_freepointer(s, p, NULL);
> > -             }
> >               start = fixup_red_left(s, start);
> >               start = setup_object(s, page, start);
> >               page->freelist = start;
> > +             for (idx = 0, p = start; idx < page->objects - 1; idx++) {
> > +                     next = p + s->size;
> > +                     next = setup_object(s, page, next);
> > +                     set_freepointer(s, p, next);
> > +                     p = next;
> > +             }
> > +             set_freepointer(s, p, NULL);
> >       }
> >
> >       page->inuse = page->objects;
> >
>
> Well, this one patch does not work here, as it throws endless errors below
> during boot. Still need this patch to fix it.

Hm, did you apply all 6 patches (the one that you sent and these five)?

>
> https://marc.info/?l=linux-mm&m=154955366113951&w=2
>
> [   85.744772] BUG kmemleak_object (Tainted: G    B        L   ): Freepointer
> corrupt
> [   85.744776]
> -----------------------------------------------------------------------------
> [   85.744776]
> [   85.744788] INFO: Allocated in create_object+0x88/0x9c8 age=2564 cpu=153 pid=1
> [   85.744797]  kmem_cache_alloc+0x39c/0x4ec
> [   85.744803]  create_object+0x88/0x9c8
> [   85.744811]  kmemleak_alloc+0xbc/0x180
> [   85.744818]  kmem_cache_alloc+0x3ec/0x4ec
> [   85.744825]  acpi_ut_create_generic_state+0x64/0xc4
> [   85.744832]  acpi_ut_create_pkg_state+0x24/0x1c8
> [   85.744840]  acpi_ut_walk_package_tree+0x268/0x564
> [   85.744848]  acpi_ns_init_one_package+0x80/0x114
> [   85.744856]  acpi_ns_init_one_object+0x214/0x3d8
> [   85.744862]  acpi_ns_walk_namespace+0x288/0x384
> [   85.744869]  acpi_walk_namespace+0xac/0xe8
> [   85.744877]  acpi_ns_initialize_objects+0x50/0x98
> [   85.744883]  acpi_load_tables+0xac/0x120
> [   85.744891]  acpi_init+0x128/0x850
> [   85.744898]  do_one_initcall+0x3ac/0x8c0
> [   85.744906]  kernel_init_freeable+0xcdc/0x1104
> [   85.744916] INFO: Freed in free_object_rcu+0x200/0x228 age=3 cpu=153 pid=0
> [   85.744923]  free_object_rcu+0x200/0x228
> [   85.744931]  rcu_process_callbacks+0xb00/0x12c0
> [   85.744937]  __do_softirq+0x644/0xfd0
> [   85.744944]  irq_exit+0x29c/0x370
> [   85.744952]  __handle_domain_irq+0xe0/0x1c4
> [   85.744958]  gic_handle_irq+0x1c4/0x3b0
> [   85.744964]  el1_irq+0xb0/0x140
> [   85.744971]  arch_cpu_idle+0x26c/0x594
> [   85.744978]  default_idle_call+0x44/0x5c
> [   85.744985]  do_idle+0x180/0x260
> [   85.744993]  cpu_startup_entry+0x24/0x28
> [   85.745001]  secondary_start_kernel+0x36c/0x440
> [   85.745009] INFO: Slab 0x(____ptrval____) objects=91 used=0
> fp=0x(____ptrval____) flags=0x17ffffffc000200
> [   85.745015] INFO: Object 0x(____ptrval____) @offset=35296 fp=0x(____ptrval____)
>
> kkkkk4.226750] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [   84.22[   84.226765] ORedzone (____ptrptrval____): 5a worker/223:0 Tainted: G
>    B        L    5.0.0-rc6+ #36
> [   84.226790] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
> BIOS L50_5.13_1.0.6 07/10/2018
> [   84.226798] Workqueue: events free_obj_work
> [   84.226802] Call trace:
> [   84.226809]  dump_backtrace+0x0/0x450
> [   84.226815]  show_stack+0x20/0x2c
> [   84.226822]  __dump_stack+0x20/0x28
> [   84.226828]  dump_stack+0xa0/0xfc
> [   84.226835]  print_trailer+0x1a8/0x1bc
> [   84.226842]  object_err+0x40/0x50
> [   84.226848]  check_object+0x214/0x2b8
> [   84.226854]  __free_slab+0x9c/0x31c
> [   84.226860]  discard_slab+0x78/0xa8
> [   84.226866]  kmem_cache_free+0x99c/0x9f0
> [   84.226873]  free_obj_work+0x92c/0xa44
> [   84.226879]  process_one_work+0x894/0x1280
> [   84.226885]  worker_thread+0x684/0xa1c
> [   84.226892]  kthread+0x2cc/0x2e8
> [   84.226898]  ret_from_fork+0x10/0x18
> [   84.229197]

