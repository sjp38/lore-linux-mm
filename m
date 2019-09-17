Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B358C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 13:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30F8B218AE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 13:24:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mjorYCcg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30F8B218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D30EB6B0006; Tue, 17 Sep 2019 09:24:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE1546B0008; Tue, 17 Sep 2019 09:24:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA83E6B000A; Tue, 17 Sep 2019 09:24:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 9345D6B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 09:24:40 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 24D9C824CA3E
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:24:40 +0000 (UTC)
X-FDA: 75944482320.14.drum67_62e61d4d23200
X-HE-Tag: drum67_62e61d4d23200
X-Filterd-Recvd-Size: 9986
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:24:39 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id z26so3048544oto.1
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 06:24:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OsdTAgCF26FzGhTn9OIgSahAZGDk0D+ef/kwXj+ZNdU=;
        b=mjorYCcgCqtRNpoNVDUFLTsinc5a4Vx0M18+lFbhTNuOfpzFkGWqWFPPtp4xpB5/l+
         jm49DKIc/rmUEsRYyiQfx1HXnk5B/ZIGbugeS5YRTwEodkOi81Y30DlntEjUsbf0W5gU
         HkrxmpX7ki5EDiexfSMIaroCmeoIONxPagkjE87FA7h7rd99yYzZ752XwYx1sbgJZj5u
         Mjx9gBSjx57tzLMS9djRGK7c+FbYNFEdkudiAZ6574xRJ3XeF7FYFrGENR9S/4GCbgrq
         grXuVyPQPInkgNG7NjsDdGI/dS8KYavdWXwekHV3xkvEBO8nM0TmNfMcG3aO3Ozn/VM7
         vE8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=OsdTAgCF26FzGhTn9OIgSahAZGDk0D+ef/kwXj+ZNdU=;
        b=AeVi6/yDUrzmnL6Vz29FMTjMcGIS44rcbRh5FnAAmDwOH7Tm8CAZ/fdp0fqo1KWCoq
         UgMywzLiACVQhzcYpYjHVqxAjnqZfz1cD1I/tpDamsjtwV848pj2vrgkBkB9L1OleTcs
         jfVu+u4pPEzBeXti6kYbzaqsc7kuMNSE9fLFEfKr437AdDYKJjZZ8UPKN7wNWumUPOgl
         wgKQiGMiweiUUHZ5OCOwPxvPMnZ35DA0WcgD1eyntnXxkJOS33gkUmA/ZKa//6GkMGvg
         hSPMASYltyaNypxRZzoEeWsBwtyfSUQIghGD9I31//4qk3BRJ9yzUSTFJuV07VOxvUjd
         JKOQ==
X-Gm-Message-State: APjAAAUmrQac4/T5RY1DyRueGqkh08T120D1oI5zIKYlXgKJhyj70Wtn
	6z1iE6eVUMcYm2PGlLIV285qKQiZqCjkotshULg=
X-Google-Smtp-Source: APXvYqzl78E9UBc7RKfHFvoRETKcham24EDV7g6CmsnN0sRuPdMdRd1oA/VK8ViDWYzx5XE3sgAR9qaGVmSEGYFF0DI=
X-Received: by 2002:a9d:6218:: with SMTP id g24mr2527384otj.326.1568726678873;
 Tue, 17 Sep 2019 06:24:38 -0700 (PDT)
MIME-Version: 1.0
References: <1568650294-8579-1-git-send-email-cai@lca.pw> <alpine.DEB.2.21.1909161128480.105847@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909161128480.105847@chino.kir.corp.google.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 17 Sep 2019 21:24:27 +0800
Message-ID: <CAD7_sbEDd+CVvMR3AGx7xvvpBHcAK8z=MBSopmXHpBepBBwPAQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/slub: remove left-over debugging code
To: David Rientjes <rientjes@google.com>
Cc: Qian Cai <cai@lca.pw>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 2:32 AM David Rientjes <rientjes@google.com> wrote:
>
> On Mon, 16 Sep 2019, Qian Cai wrote:
>
> > SLUB_RESILIENCY_TEST and SLUB_DEBUG_CMPXCHG look like some left-over
> > debugging code during the internal development that probably nobody uses
> > it anymore. Remove them to make the world greener.
>
> Adding Pengfei Li who has been working on a patchset for modified handling
> of kmalloc cache initialization and touches the resiliency test.
>

Thanks for looping me in.

My opinion is the same as David Rientjes.
The resiliency test should not be removed but should be improved.

> I still find the resiliency test to be helpful/instructional for handling
> unexpected conditions in these caches, so I'd suggest against removing it:
> the only downside is that it's additional source code.  But it's helpful
> source code for reference.
>
> The cmpxchg failures could likely be more generalized beyond SLUB since
> there will be other dependencies in the kernel than just this allocator.
>
> (I assume you didn't send a Signed-off-by line because this is an RFC.)
>
> > ---
> >  mm/slub.c | 110 --------------------------------------------------------------
> >  1 file changed, 110 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 8834563cdb4b..f97155ba097d 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -150,12 +150,6 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
> >   * - Variable sizing of the per node arrays
> >   */
> >
> > -/* Enable to test recovery from slab corruption on boot */
> > -#undef SLUB_RESILIENCY_TEST
> > -
> > -/* Enable to log cmpxchg failures */
> > -#undef SLUB_DEBUG_CMPXCHG
> > -
> >  /*
> >   * Mininum number of partial slabs. These will be left on the partial
> >   * lists even if they are empty. kmem_cache_shrink may reclaim them.
> > @@ -392,10 +386,6 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
> >       cpu_relax();
> >       stat(s, CMPXCHG_DOUBLE_FAIL);
> >
> > -#ifdef SLUB_DEBUG_CMPXCHG
> > -     pr_info("%s %s: cmpxchg double redo ", n, s->name);
> > -#endif
> > -
> >       return false;
> >  }
> >
> > @@ -433,10 +423,6 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
> >       cpu_relax();
> >       stat(s, CMPXCHG_DOUBLE_FAIL);
> >
> > -#ifdef SLUB_DEBUG_CMPXCHG
> > -     pr_info("%s %s: cmpxchg double redo ", n, s->name);
> > -#endif
> > -
> >       return false;
> >  }
> >
> > @@ -2004,45 +1990,11 @@ static inline unsigned long next_tid(unsigned long tid)
> >       return tid + TID_STEP;
> >  }
> >
> > -static inline unsigned int tid_to_cpu(unsigned long tid)
> > -{
> > -     return tid % TID_STEP;
> > -}
> > -
> > -static inline unsigned long tid_to_event(unsigned long tid)
> > -{
> > -     return tid / TID_STEP;
> > -}
> > -
> >  static inline unsigned int init_tid(int cpu)
> >  {
> >       return cpu;
> >  }
> >
> > -static inline void note_cmpxchg_failure(const char *n,
> > -             const struct kmem_cache *s, unsigned long tid)
> > -{
> > -#ifdef SLUB_DEBUG_CMPXCHG
> > -     unsigned long actual_tid = __this_cpu_read(s->cpu_slab->tid);
> > -
> > -     pr_info("%s %s: cmpxchg redo ", n, s->name);
> > -
> > -#ifdef CONFIG_PREEMPT
> > -     if (tid_to_cpu(tid) != tid_to_cpu(actual_tid))
> > -             pr_warn("due to cpu change %d -> %d\n",
> > -                     tid_to_cpu(tid), tid_to_cpu(actual_tid));
> > -     else
> > -#endif
> > -     if (tid_to_event(tid) != tid_to_event(actual_tid))
> > -             pr_warn("due to cpu running other code. Event %ld->%ld\n",
> > -                     tid_to_event(tid), tid_to_event(actual_tid));
> > -     else
> > -             pr_warn("for unknown reason: actual=%lx was=%lx target=%lx\n",
> > -                     actual_tid, tid, next_tid(tid));
> > -#endif
> > -     stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
> > -}
> > -
> >  static void init_kmem_cache_cpus(struct kmem_cache *s)
> >  {
> >       int cpu;
> > @@ -2751,7 +2703,6 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
> >                               object, tid,
> >                               next_object, next_tid(tid)))) {
> >
> > -                     note_cmpxchg_failure("slab_alloc", s, tid);
> >                       goto redo;
> >               }
> >               prefetch_freepointer(s, next_object);
> > @@ -4694,66 +4645,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
> >  }
> >  #endif       /* CONFIG_SLUB_DEBUG */
> >
> > -#ifdef SLUB_RESILIENCY_TEST
> > -static void __init resiliency_test(void)
> > -{
> > -     u8 *p;
> > -     int type = KMALLOC_NORMAL;
> > -
> > -     BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || KMALLOC_SHIFT_HIGH < 10);
> > -
> > -     pr_err("SLUB resiliency testing\n");
> > -     pr_err("-----------------------\n");
> > -     pr_err("A. Corruption after allocation\n");
> > -
> > -     p = kzalloc(16, GFP_KERNEL);
> > -     p[16] = 0x12;
> > -     pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
> > -            p + 16);
> > -
> > -     validate_slab_cache(kmalloc_caches[type][4]);
> > -
> > -     /* Hmmm... The next two are dangerous */
> > -     p = kzalloc(32, GFP_KERNEL);
> > -     p[32 + sizeof(void *)] = 0x34;
> > -     pr_err("\n2. kmalloc-32: Clobber next pointer/next slab 0x34 -> -0x%p\n",
> > -            p);
> > -     pr_err("If allocated object is overwritten then not detectable\n\n");
> > -
> > -     validate_slab_cache(kmalloc_caches[type][5]);
> > -     p = kzalloc(64, GFP_KERNEL);
> > -     p += 64 + (get_cycles() & 0xff) * sizeof(void *);
> > -     *p = 0x56;
> > -     pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
> > -            p);
> > -     pr_err("If allocated object is overwritten then not detectable\n\n");
> > -     validate_slab_cache(kmalloc_caches[type][6]);
> > -
> > -     pr_err("\nB. Corruption after free\n");
> > -     p = kzalloc(128, GFP_KERNEL);
> > -     kfree(p);
> > -     *p = 0x78;
> > -     pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
> > -     validate_slab_cache(kmalloc_caches[type][7]);
> > -
> > -     p = kzalloc(256, GFP_KERNEL);
> > -     kfree(p);
> > -     p[50] = 0x9a;
> > -     pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
> > -     validate_slab_cache(kmalloc_caches[type][8]);
> > -
> > -     p = kzalloc(512, GFP_KERNEL);
> > -     kfree(p);
> > -     p[512] = 0xab;
> > -     pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
> > -     validate_slab_cache(kmalloc_caches[type][9]);
> > -}
> > -#else
> > -#ifdef CONFIG_SYSFS
> > -static void resiliency_test(void) {};
> > -#endif
> > -#endif       /* SLUB_RESILIENCY_TEST */
> > -
> >  #ifdef CONFIG_SYSFS
> >  enum slab_stat_type {
> >       SL_ALL,                 /* All slabs */
> > @@ -5875,7 +5766,6 @@ static int __init slab_sysfs_init(void)
> >       }
> >
> >       mutex_unlock(&slab_mutex);
> > -     resiliency_test();
> >       return 0;
> >  }
> >
> > --
> > 1.8.3.1
> >
> >

