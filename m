Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09976C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B32C7214D9
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:32:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iOe1j1jF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B32C7214D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363496B0003; Mon, 16 Sep 2019 14:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 316C66B0006; Mon, 16 Sep 2019 14:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2025D6B0007; Mon, 16 Sep 2019 14:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id F25F86B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:32:30 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8A65C6D7F
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:32:30 +0000 (UTC)
X-FDA: 75941629260.29.sense43_6d2493b91965d
X-HE-Tag: sense43_6d2493b91965d
X-Filterd-Recvd-Size: 9241
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:32:29 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id i18so459085pgl.11
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:32:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=DfC+q6n84zbhMpsDUftY8nxKWK1YxhqqrQVWMmDQ1iE=;
        b=iOe1j1jFBJLIr9wC3amj30A7BR8L42Sepf+99X8Xw+0aQFxFpVXVoAxma3Oij5vac7
         kXvSwwsp4qasO2wuU1dZWyGYSZBrelQF+cuWdZLWR5SUXroXVUh/cmCWTBx1yI9i9b23
         /VHzN5ia0Ww/wPdChU+2n6abo1xVMd7vweUZIMu2mOCkdX6FJKhViR46dYKvG+c9wNCu
         4608Z2uj/T2ndpqN1ADEVhcLJLlaarv8wgpltM0OoLdZFkoNoP/eEX+OA9N3Qx3Ll6Wg
         OSQcpsegLSfKnKbYNB/fVQSEzlYc+oLHd1c2LkLXYZxmsX1Qs5E/5fOF49ehIn+dhC0H
         Mf2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=DfC+q6n84zbhMpsDUftY8nxKWK1YxhqqrQVWMmDQ1iE=;
        b=Am2lTa31+rPqs20QOCQmqLevrDm3f0YK8nFHroOne6wFU81oNlxUdewOOP+/+VOYQe
         6a4mFd3FDyytx6oJRPk9IxP7VqqwGvO2tm2rPK/0TkJVA6OkEEs0t44GcVLhNmHAgB2y
         43rEPKBn/u/nhzIAWytqTtXBY9gH9MEyFePzqcvrpsSXh+VVR8FcxZ7D81ZG7FZX8pGo
         czNVJSRa0EJ3/pL8qt7b33ic01/AF5hRhNZO+Hiv48TjPYh6F2UO6wTqcuPfRHus6a1G
         rEDskE2Gvaly8uCIFGW1gIIgMetWIZcgKaqbDFyHqj8bsintFtL5dCrWhtFlarB1NaYj
         1X2A==
X-Gm-Message-State: APjAAAXIXjq7B+pGhP+T/qkqLt+AI4Ft21zWL9Mn4KARFQZrNcWs8Cd8
	DubttqDvCT2tRBO6UIxkGpxO3g==
X-Google-Smtp-Source: APXvYqyQP1cm9FOGzbIbT2loFwSSgsLlA/qIbFLKgPeoOGK1abPX9tBd6nq620wfTUZjC+VOx4VG9g==
X-Received: by 2002:a65:4002:: with SMTP id f2mr440594pgp.447.1568658748539;
        Mon, 16 Sep 2019 11:32:28 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id v4sm842126pff.181.2019.09.16.11.32.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 11:32:27 -0700 (PDT)
Date: Mon, 16 Sep 2019 11:32:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Qian Cai <cai@lca.pw>, Pengfei Li <lpf.vector@gmail.com>
cc: cl@linux.com, penberg@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm/slub: remove left-over debugging code
In-Reply-To: <1568650294-8579-1-git-send-email-cai@lca.pw>
Message-ID: <alpine.DEB.2.21.1909161128480.105847@chino.kir.corp.google.com>
References: <1568650294-8579-1-git-send-email-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Qian Cai wrote:

> SLUB_RESILIENCY_TEST and SLUB_DEBUG_CMPXCHG look like some left-over
> debugging code during the internal development that probably nobody uses
> it anymore. Remove them to make the world greener.

Adding Pengfei Li who has been working on a patchset for modified handling 
of kmalloc cache initialization and touches the resiliency test.

I still find the resiliency test to be helpful/instructional for handling 
unexpected conditions in these caches, so I'd suggest against removing it: 
the only downside is that it's additional source code.  But it's helpful 
source code for reference.

The cmpxchg failures could likely be more generalized beyond SLUB since 
there will be other dependencies in the kernel than just this allocator.

(I assume you didn't send a Signed-off-by line because this is an RFC.)

> ---
>  mm/slub.c | 110 --------------------------------------------------------------
>  1 file changed, 110 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 8834563cdb4b..f97155ba097d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -150,12 +150,6 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
>   * - Variable sizing of the per node arrays
>   */
>  
> -/* Enable to test recovery from slab corruption on boot */
> -#undef SLUB_RESILIENCY_TEST
> -
> -/* Enable to log cmpxchg failures */
> -#undef SLUB_DEBUG_CMPXCHG
> -
>  /*
>   * Mininum number of partial slabs. These will be left on the partial
>   * lists even if they are empty. kmem_cache_shrink may reclaim them.
> @@ -392,10 +386,6 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
>  	cpu_relax();
>  	stat(s, CMPXCHG_DOUBLE_FAIL);
>  
> -#ifdef SLUB_DEBUG_CMPXCHG
> -	pr_info("%s %s: cmpxchg double redo ", n, s->name);
> -#endif
> -
>  	return false;
>  }
>  
> @@ -433,10 +423,6 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
>  	cpu_relax();
>  	stat(s, CMPXCHG_DOUBLE_FAIL);
>  
> -#ifdef SLUB_DEBUG_CMPXCHG
> -	pr_info("%s %s: cmpxchg double redo ", n, s->name);
> -#endif
> -
>  	return false;
>  }
>  
> @@ -2004,45 +1990,11 @@ static inline unsigned long next_tid(unsigned long tid)
>  	return tid + TID_STEP;
>  }
>  
> -static inline unsigned int tid_to_cpu(unsigned long tid)
> -{
> -	return tid % TID_STEP;
> -}
> -
> -static inline unsigned long tid_to_event(unsigned long tid)
> -{
> -	return tid / TID_STEP;
> -}
> -
>  static inline unsigned int init_tid(int cpu)
>  {
>  	return cpu;
>  }
>  
> -static inline void note_cmpxchg_failure(const char *n,
> -		const struct kmem_cache *s, unsigned long tid)
> -{
> -#ifdef SLUB_DEBUG_CMPXCHG
> -	unsigned long actual_tid = __this_cpu_read(s->cpu_slab->tid);
> -
> -	pr_info("%s %s: cmpxchg redo ", n, s->name);
> -
> -#ifdef CONFIG_PREEMPT
> -	if (tid_to_cpu(tid) != tid_to_cpu(actual_tid))
> -		pr_warn("due to cpu change %d -> %d\n",
> -			tid_to_cpu(tid), tid_to_cpu(actual_tid));
> -	else
> -#endif
> -	if (tid_to_event(tid) != tid_to_event(actual_tid))
> -		pr_warn("due to cpu running other code. Event %ld->%ld\n",
> -			tid_to_event(tid), tid_to_event(actual_tid));
> -	else
> -		pr_warn("for unknown reason: actual=%lx was=%lx target=%lx\n",
> -			actual_tid, tid, next_tid(tid));
> -#endif
> -	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
> -}
> -
>  static void init_kmem_cache_cpus(struct kmem_cache *s)
>  {
>  	int cpu;
> @@ -2751,7 +2703,6 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
>  				object, tid,
>  				next_object, next_tid(tid)))) {
>  
> -			note_cmpxchg_failure("slab_alloc", s, tid);
>  			goto redo;
>  		}
>  		prefetch_freepointer(s, next_object);
> @@ -4694,66 +4645,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
>  }
>  #endif	/* CONFIG_SLUB_DEBUG */
>  
> -#ifdef SLUB_RESILIENCY_TEST
> -static void __init resiliency_test(void)
> -{
> -	u8 *p;
> -	int type = KMALLOC_NORMAL;
> -
> -	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || KMALLOC_SHIFT_HIGH < 10);
> -
> -	pr_err("SLUB resiliency testing\n");
> -	pr_err("-----------------------\n");
> -	pr_err("A. Corruption after allocation\n");
> -
> -	p = kzalloc(16, GFP_KERNEL);
> -	p[16] = 0x12;
> -	pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
> -	       p + 16);
> -
> -	validate_slab_cache(kmalloc_caches[type][4]);
> -
> -	/* Hmmm... The next two are dangerous */
> -	p = kzalloc(32, GFP_KERNEL);
> -	p[32 + sizeof(void *)] = 0x34;
> -	pr_err("\n2. kmalloc-32: Clobber next pointer/next slab 0x34 -> -0x%p\n",
> -	       p);
> -	pr_err("If allocated object is overwritten then not detectable\n\n");
> -
> -	validate_slab_cache(kmalloc_caches[type][5]);
> -	p = kzalloc(64, GFP_KERNEL);
> -	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
> -	*p = 0x56;
> -	pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
> -	       p);
> -	pr_err("If allocated object is overwritten then not detectable\n\n");
> -	validate_slab_cache(kmalloc_caches[type][6]);
> -
> -	pr_err("\nB. Corruption after free\n");
> -	p = kzalloc(128, GFP_KERNEL);
> -	kfree(p);
> -	*p = 0x78;
> -	pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
> -	validate_slab_cache(kmalloc_caches[type][7]);
> -
> -	p = kzalloc(256, GFP_KERNEL);
> -	kfree(p);
> -	p[50] = 0x9a;
> -	pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
> -	validate_slab_cache(kmalloc_caches[type][8]);
> -
> -	p = kzalloc(512, GFP_KERNEL);
> -	kfree(p);
> -	p[512] = 0xab;
> -	pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
> -	validate_slab_cache(kmalloc_caches[type][9]);
> -}
> -#else
> -#ifdef CONFIG_SYSFS
> -static void resiliency_test(void) {};
> -#endif
> -#endif	/* SLUB_RESILIENCY_TEST */
> -
>  #ifdef CONFIG_SYSFS
>  enum slab_stat_type {
>  	SL_ALL,			/* All slabs */
> @@ -5875,7 +5766,6 @@ static int __init slab_sysfs_init(void)
>  	}
>  
>  	mutex_unlock(&slab_mutex);
> -	resiliency_test();
>  	return 0;
>  }
>  
> -- 
> 1.8.3.1
> 
> 

