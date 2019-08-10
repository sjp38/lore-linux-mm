Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA11BC32751
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 09:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EC762166E
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 09:05:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WvlE/0bj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EC762166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B275A6B0005; Sat, 10 Aug 2019 05:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAFD26B0006; Sat, 10 Aug 2019 05:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 978036B0007; Sat, 10 Aug 2019 05:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35BAA6B0005
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 05:05:39 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 17so19704275ljc.20
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 02:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=x/iVkWacMKBMI8tUTq90sb+qNE12YPEmDRdfDkGujEg=;
        b=ef5v26adXsulVtf/6O9IXM+hbZpuBXHsIPVgJmgSER9qOrXN2LANh+CG9/kE/zQisp
         T9xW3aXwTKWYBV7pE3a4WNa6JL8qARvJIuxYRvkWikP5jYQutCfplEzSQVjopND+bLN3
         JaS0+msF8q8vwCiz37JoGTl+76/mHUSawfSU2vahULVz3tOtEMu4XDiZtV+iE1ELJgFp
         dYEXX+Sg3leyHCgSgEC6LP/OaviRQFjOh/gV37zJJ9HbvUPWoxRJTmbA+Gglk6LBdP49
         aiCCOo6nq3PIo2k9mpenNZu4iOvMu7YWJR/zC0mRp0Qm+V/OTW08wh/39RK2fLa+zQqK
         J/qQ==
X-Gm-Message-State: APjAAAVIMSjsRnZo67R065woqIF4y/TdG8OaQwWpU8P0Xg1IQ6oX49Ic
	Ti+4ucwb1UmxAjtlsqhkvb+4/Z6hGFv2JPU3k1vn+VHypWPkVve5YxNKh3KAcvkOlb7zZMubGVh
	S1MkzCx6aZ3hDDrgl5pyezyXfU4U/6y+SiHY6ed+SitPW0ygTm0pZ+w2rObp+3P+WeQ==
X-Received: by 2002:a19:dc14:: with SMTP id t20mr6744485lfg.182.1565427938319;
        Sat, 10 Aug 2019 02:05:38 -0700 (PDT)
X-Received: by 2002:a19:dc14:: with SMTP id t20mr6744457lfg.182.1565427937299;
        Sat, 10 Aug 2019 02:05:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565427937; cv=none;
        d=google.com; s=arc-20160816;
        b=nZiL/X5PJd6FCeK7SsLJG+wH309Nk/wFL7PqSJDFsrvH0/ldbil4HEnQCauBB6N0hY
         WhKJh9vJoNUd+VBR7b0OjWWgBC91gDH6ALP2HEu0/70PEhXCfpOfmEerWvVtGwCcT2YM
         vICYhDG0GydYEgBorWDBQiZDSgvElYlRhfpwKOgRE36CrjfPUrEtA9ZrNudrwQD58QzD
         2lB3aQ66TzgD2YgCEha05v4Va5hIL5mrCwSdZzKv8O5bIhQpy/Auhbo3F9hsGMtcCbU9
         OXFVxNE0Jr5h2ipHMVU3SAuIjLB41r8/6qCbzIhdXuD/DD0oK5sz51vRVWAWi8CUxxUc
         2wBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=x/iVkWacMKBMI8tUTq90sb+qNE12YPEmDRdfDkGujEg=;
        b=JHqrjC4xW6GT0f8CS9VDv4IJJ3bpeyBQNrxyjMJ22TR847Lry9sQN+h01hh/AzP0Oc
         9+DxHKKy1kve+JE8X7Rj4gjDEv9Zfk8xxyHSc7iXRg0BkPx+QE7U/cC2vHGSGWc8QyUR
         968FRHkawc10wnEe1g8oiLTvXh7MK8FCGLxFW7DbfZWISEWzzko6Ffloh5AFr3XWIdSV
         hqj1R6kQHkXrNF8dSiT8t8MruBVwICCrY16CZtOgUHusDXvvRXm0W1kiG6UbqrUdhGSq
         gwDY3/vka6LekbpZqaE8vdTxJudNJyNp5DFumDJpTpOdTbEHq/qhN3ARXzYBwvLzv8sg
         2lsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="WvlE/0bj";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j3sor53191975ljg.20.2019.08.10.02.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 02:05:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="WvlE/0bj";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x/iVkWacMKBMI8tUTq90sb+qNE12YPEmDRdfDkGujEg=;
        b=WvlE/0bjif9cFAUGbIm/f0nu8+dOOpAZMPm9E+uI8zYm4MQUaeFnTN0/mLAbdeOfCI
         x3IN08Godktf7mrpJ4w+H6zi9+7XgTOBEnva1iHxVbFc3hU+4fq/w5vvz7mw0oYfAeuf
         eRNRgpMPMdbEH6h9IYz+5voskY5PFplpNp3SZQAe/tSwhdW2g8V3wR0i/fE2r7HXSxvt
         zmphBIxc1HKujLmnct8w+4coO6/9/COYW9sMx37l/pGHOVNi7vxizxw122bkUMEwiYkQ
         9B0b/5ViG93yQn/yadNuscw4Pd3eK/lthDz87lcR42UJ5iz/3m2qR+/GciYvZdbRmU9/
         4sjQ==
X-Google-Smtp-Source: APXvYqyXg4louOiSmPQuA3Tvk5SIs5REwboG+lRAcYog6St+Vb6efmyfq6z/WGumJAIIF26yBbDsKB+52JdmLRLZQi8=
X-Received: by 2002:a2e:720b:: with SMTP id n11mr4092017ljc.213.1565427936877;
 Sat, 10 Aug 2019 02:05:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190809164643.5978-1-henryburns@google.com>
In-Reply-To: <20190809164643.5978-1-henryburns@google.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sat, 10 Aug 2019 12:05:23 +0300
Message-ID: <CAMJBoFPi3bzRdC8J4tacSHOgP6Z4=KGuT2FLUNVY=EYZ6wEFKg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix race between migration and destruction
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Henry,

Den fre 9 aug. 2019 6:46 emHenry Burns <henryburns@google.com> skrev:
>
> In z3fold_destroy_pool() we call destroy_workqueue(&pool->compact_wq).
> However, we have no guarantee that migration isn't happening in the
> background at that time.
>
> Migration directly calls queue_work_on(pool->compact_wq), if destruction
> wins that race we are using a destroyed workqueue.


Thanks for the fix. Would you please comment why adding
flush_workqueue() isn't enough?

~Vitaly
>
>
> Signed-off-by: Henry Burns <henryburns@google.com>
> ---
>  mm/z3fold.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 51 insertions(+)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 78447cecfffa..e136d97ce56e 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -40,6 +40,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/slab.h>
>  #include <linux/spinlock.h>
> +#include <linux/wait.h>
>  #include <linux/zpool.h>
>
>  /*
> @@ -161,8 +162,10 @@ struct z3fold_pool {
>         const struct zpool_ops *zpool_ops;
>         struct workqueue_struct *compact_wq;
>         struct workqueue_struct *release_wq;
> +       struct wait_queue_head isolate_wait;
>         struct work_struct work;
>         struct inode *inode;
> +       int isolated_pages;
>  };
>
>  /*
> @@ -772,6 +775,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>                 goto out_c;
>         spin_lock_init(&pool->lock);
>         spin_lock_init(&pool->stale_lock);
> +       init_waitqueue_head(&pool->isolate_wait);
>         pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
>         if (!pool->unbuddied)
>                 goto out_pool;
> @@ -811,6 +815,15 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>         return NULL;
>  }
>
> +static bool pool_isolated_are_drained(struct z3fold_pool *pool)
> +{
> +       bool ret;
> +
> +       spin_lock(&pool->lock);
> +       ret = pool->isolated_pages == 0;
> +       spin_unlock(&pool->lock);
> +       return ret;
> +}
>  /**
>   * z3fold_destroy_pool() - destroys an existing z3fold pool
>   * @pool:      the z3fold pool to be destroyed
> @@ -821,6 +834,13 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>  {
>         kmem_cache_destroy(pool->c_handle);
>
> +       /*
> +        * We need to ensure that no pages are being migrated while we destroy
> +        * these workqueues, as migration can queue work on either of the
> +        * workqueues.
> +        */
> +       wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
> +
>         /*
>          * We need to destroy pool->compact_wq before pool->release_wq,
>          * as any pending work on pool->compact_wq will call
> @@ -1317,6 +1337,28 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
>         return atomic64_read(&pool->pages_nr);
>  }
>
> +/*
> + * z3fold_dec_isolated() expects to be called while pool->lock is held.
> + */
> +static void z3fold_dec_isolated(struct z3fold_pool *pool)
> +{
> +       assert_spin_locked(&pool->lock);
> +       VM_BUG_ON(pool->isolated_pages <= 0);
> +       pool->isolated_pages--;
> +
> +       /*
> +        * If we have no more isolated pages, we have to see if
> +        * z3fold_destroy_pool() is waiting for a signal.
> +        */
> +       if (pool->isolated_pages == 0 && waitqueue_active(&pool->isolate_wait))
> +               wake_up_all(&pool->isolate_wait);
> +}
> +
> +static void z3fold_inc_isolated(struct z3fold_pool *pool)
> +{
> +       pool->isolated_pages++;
> +}
> +
>  static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>  {
>         struct z3fold_header *zhdr;
> @@ -1343,6 +1385,7 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>                 spin_lock(&pool->lock);
>                 if (!list_empty(&page->lru))
>                         list_del(&page->lru);
> +               z3fold_inc_isolated(pool);
>                 spin_unlock(&pool->lock);
>                 z3fold_page_unlock(zhdr);
>                 return true;
> @@ -1417,6 +1460,10 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>
>         queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
>
> +       spin_lock(&pool->lock);
> +       z3fold_dec_isolated(pool);
> +       spin_unlock(&pool->lock);
> +
>         page_mapcount_reset(page);
>         put_page(page);
>         return 0;
> @@ -1436,10 +1483,14 @@ static void z3fold_page_putback(struct page *page)
>         INIT_LIST_HEAD(&page->lru);
>         if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
>                 atomic64_dec(&pool->pages_nr);
> +               spin_lock(&pool->lock);
> +               z3fold_dec_isolated(pool);
> +               spin_unlock(&pool->lock);
>                 return;
>         }
>         spin_lock(&pool->lock);
>         list_add(&page->lru, &pool->lru);
> +       z3fold_dec_isolated(pool);
>         spin_unlock(&pool->lock);
>         z3fold_page_unlock(zhdr);
>  }
> --
> 2.22.0.770.g0f2c4a37fd-goog
>

