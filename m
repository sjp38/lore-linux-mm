Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06801C07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 22:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81CD720856
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 22:09:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IQRUA5tk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81CD720856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A9C26B0007; Sat, 25 May 2019 18:09:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 133CB6B0008; Sat, 25 May 2019 18:09:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEE196B000A; Sat, 25 May 2019 18:09:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36F46B0007
	for <linux-mm@kvack.org>; Sat, 25 May 2019 18:09:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so10028350pfn.6
        for <linux-mm@kvack.org>; Sat, 25 May 2019 15:09:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TV8EsVeMu4YeAhPJsTlZrygXkRdkbDyZshxow2Cuz/w=;
        b=gCxkNZqJlGYEEp+6wEY9jYoUm3d89Bb4g/86kNhlI0Ww3xPwTxyxT8tIBtHZ5gKZEi
         NuYuRsraGF/9dsZvD+sAJ5tycArjYX0Te5vUzC4cBOXW9Wy+bBoNPo+Zi0ym3aK0pX0i
         zy56/7gsRF2lmA0qbnBuYUmllS/rqf2qhaVZw3mGKmnGFTecq3mLoqH4M1LKj8fc38pl
         IlIkjBV9pVn5qB7tWC6zZICuw7bJnBmd270YSspuWxyLjbw6gi4E2wj8k0r4R1d0aFR7
         cUIaAJzMLRexR3V6rGFZBivAv/GI9/GAkZD56KTlHU1E1/+lKRY7kHYx8QgT1GcX3IC8
         2cdA==
X-Gm-Message-State: APjAAAWXtryyHGRz3VTXx52vm44AoZMQDrvka65q3DGRYIj4YnnIN64L
	dErkBiFun0TQm7rNj87CSU5LL9oD7c19jCgCmM6uzIIPZchkvZgjERz2otANAhHYd7Nt2hxgVBN
	EyugzsfH9+yWQVtpYEEN/4DP4cuc9XFmzs4Bx2xT1Lh8gl/grJahshsCHETrN2Gft7g==
X-Received: by 2002:a63:5443:: with SMTP id e3mr3949300pgm.265.1558822191174;
        Sat, 25 May 2019 15:09:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvLpA9ZawJWsQmpAtj/8J4Iq4xmiBzQ/hv+WU+mK19OvUqYsMp4OPBFjgiO515f/wT58Om
X-Received: by 2002:a63:5443:: with SMTP id e3mr3949199pgm.265.1558822190077;
        Sat, 25 May 2019 15:09:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558822190; cv=none;
        d=google.com; s=arc-20160816;
        b=GYrUBOe6lEIyHCObueYuRPFy14+EPi54yL6Sb2WWLr8LXSljxMzFwtPgomYkx/g3sh
         JBaL4wZtrXBuDjhqO0itHjdrg9qgarCa4+bOf51zQ6vm/w17KSPozgHPqfXtWyS8o9nW
         qEtXabpKol9ZBuIoaSc3a0JBLNzHVKqQp28h5EJt/YJOnw0SEeZsSpeFdOfV3cTIVyri
         wit9AB24jdcn/glCBqFbb5B6buVHwnSBcqaig4ha67SdNaxhtPuunWEnxUtsiFZIU1KJ
         6vZC/7ro15sxVa2OJzL7mTv3RHczOFfmLqEQSn6vtXHXjGlC0Nw4jfvSrQPCvu0FgiDi
         uRZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TV8EsVeMu4YeAhPJsTlZrygXkRdkbDyZshxow2Cuz/w=;
        b=QPV0sxkB+Rnw0zl6E+B5a+g/0qlT2WcupO7F4GGSU7cOh4hFyj0qA+qnJeS8SdpbbK
         Vp2m6ndN4MU3lCYTqoG06DYHlusR/QQKzk0NKE8KDQLvP1TkvYEDxTIFyqLmfvR3zpKw
         ftLDUg+tJCwCgDZQGrBmDOeNWdL5INlFhHbL8XUBJUiFk5zamM+qpSdHNLpMPO7YJeQU
         o5BUY53nzZZl1kOhRHHuriPEiuVEnVmMr+aUeMEcSyRn2iROkqNNDKxK2JFoqYAMxGSd
         E9U9ULNWpDlKz651sgNcBMtnK2joPjCeb0D9GRcJAvmB1n6yV2VyCHpIFV8gXHyK/PaK
         dPgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IQRUA5tk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 18si12640113pfy.280.2019.05.25.15.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 15:09:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IQRUA5tk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4322120815;
	Sat, 25 May 2019 22:09:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558822189;
	bh=VuyQV9yCcfmzDbrICJDTkT3K0+YFQkMCZif6CxZr9/4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=IQRUA5tkhswTF2Ciz/q+MUTYpYHiMtvkI3APccoGTImDGfdlv5vmiGY5LrGrHMTKN
	 H/Or5yB8oZzFuI5ssnXzUeMz5mTrGxdtkgFwmp59zW2pqjrbHutRzawwgO5y8R4mCH
	 PfjyYmoFSkzBP7IcoZi8FEjLWBDmxLPlonQLTcu8=
Date: Sat, 25 May 2019 15:09:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan
 Streetman <ddstreet@ieee.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Uladzislau Rezki
 <urezki@gmail.com>
Subject: Re: [PATCH] z3fold: add inter-page compaction
Message-Id: <20190525150948.e1ff1a2a894ca8110abc8183@linux-foundation.org>
In-Reply-To: <20190524174918.71074b358001bdbf1c23cd77@gmail.com>
References: <20190524174918.71074b358001bdbf1c23cd77@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 May 2019 17:49:18 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> For each page scheduled for compaction (e. g. by z3fold_free()),
> try to apply inter-page compaction before running the traditional/
> existing intra-page compaction. That means, if the page has only one
> buddy, we treat that buddy as a new object that we aim to place into
> an existing z3fold page. If such a page is found, that object is
> transferred and the old page is freed completely. The transferred
> object is named "foreign" and treated slightly differently thereafter.
> 
> Namely, we increase "foreign handle" counter for the new page. Pages
> with non-zero "foreign handle" count become unmovable. This patch
> implements "foreign handle" detection when a handle is freed to
> decrement the foreign handle counter accordingly, so a page may as
> well become movable again as the time goes by.
> 
> As a result, we almost always have exactly 3 objects per page and
> significantly better average compression ratio.
> 
> ...
>
> +static inline struct z3fold_header *handle_to_z3fold_header(unsigned long);
> +static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *);

Forward-declaring inline functions is peculiar, but it does appear to work.

z3fold is quite inline-happy.  Fortunately the compiler will ignore the
inline hint if it seems a bad idea.  Even then, the below shrinks
z3fold.o text from 30k to 27k.  Which might even make it faster....

--- a/mm/z3fold.c~a
+++ a/mm/z3fold.c
@@ -185,8 +185,8 @@ enum z3fold_handle_flags {
 	HANDLES_ORPHANED = 0,
 };
 
-static inline struct z3fold_header *handle_to_z3fold_header(unsigned long);
-static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *);
+static struct z3fold_header *handle_to_z3fold_header(unsigned long);
+static struct z3fold_pool *zhdr_to_pool(struct z3fold_header *);
 static struct z3fold_header *__z3fold_alloc(struct z3fold_pool *, size_t, bool);
 static void add_to_unbuddied(struct z3fold_pool *, struct z3fold_header *);
 
@@ -205,7 +205,7 @@ static int size_to_chunks(size_t size)
 
 static void compact_page_work(struct work_struct *w);
 
-static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
+static struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
 							gfp_t gfp)
 {
 	struct z3fold_buddy_slots *slots = kmem_cache_alloc(pool->c_handle,
@@ -220,17 +220,17 @@ static inline struct z3fold_buddy_slots
 	return slots;
 }
 
-static inline struct z3fold_pool *slots_to_pool(struct z3fold_buddy_slots *s)
+static struct z3fold_pool *slots_to_pool(struct z3fold_buddy_slots *s)
 {
 	return (struct z3fold_pool *)(s->pool & ~HANDLE_FLAG_MASK);
 }
 
-static inline struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
+static struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
 {
 	return (struct z3fold_buddy_slots *)(handle & ~(SLOTS_ALIGN - 1));
 }
 
-static inline void free_handle(unsigned long handle)
+static void free_handle(unsigned long handle)
 {
 	struct z3fold_buddy_slots *slots;
 	struct z3fold_header *zhdr;
@@ -423,7 +423,7 @@ static unsigned long encode_handle(struc
 	return (unsigned long)&slots->slot[idx];
 }
 
-static inline struct z3fold_header *__get_z3fold_header(unsigned long handle,
+static struct z3fold_header *__get_z3fold_header(unsigned long handle,
 							bool lock)
 {
 	struct z3fold_buddy_slots *slots;
@@ -648,7 +648,7 @@ static int num_free_chunks(struct z3fold
 }
 
 /* Add to the appropriate unbuddied list */
-static inline void add_to_unbuddied(struct z3fold_pool *pool,
+static void add_to_unbuddied(struct z3fold_pool *pool,
 				struct z3fold_header *zhdr)
 {
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
@@ -664,7 +664,7 @@ static inline void add_to_unbuddied(stru
 	}
 }
 
-static inline void *mchunk_memmove(struct z3fold_header *zhdr,
+static void *mchunk_memmove(struct z3fold_header *zhdr,
 				unsigned short dst_chunk)
 {
 	void *beg = zhdr;
@@ -673,7 +673,7 @@ static inline void *mchunk_memmove(struc
 		       zhdr->middle_chunks << CHUNK_SHIFT);
 }
 
-static inline bool buddy_single(struct z3fold_header *zhdr)
+static bool buddy_single(struct z3fold_header *zhdr)
 {
 	return !((zhdr->first_chunks && zhdr->middle_chunks) ||
 			(zhdr->first_chunks && zhdr->last_chunks) ||
@@ -884,7 +884,7 @@ static void compact_page_work(struct wor
 }
 
 /* returns _locked_ z3fold page header or NULL */
-static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
+static struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
 						size_t size, bool can_sleep)
 {
 	struct z3fold_header *zhdr = NULL;
_


>
> ...
>
> +static inline struct z3fold_header *__get_z3fold_header(unsigned long handle,
> +							bool lock)
> +{
> +	struct z3fold_buddy_slots *slots;
> +	struct z3fold_header *zhdr;
> +	unsigned int seq;
> +	bool is_valid;
> +
> +	if (!(handle & (1 << PAGE_HEADLESS))) {
> +		slots = handle_to_slots(handle);
> +		do {
> +			unsigned long addr;
> +
> +			seq = read_seqbegin(&slots->seqlock);
> +			addr = *(unsigned long *)handle;
> +			zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
> +			preempt_disable();

Why is this done?

> +			is_valid = !read_seqretry(&slots->seqlock, seq);
> +			if (!is_valid) {
> +				preempt_enable();
> +				continue;
> +			}
> +			/*
> +			 * if we are here, zhdr is a pointer to a valid z3fold
> +			 * header. Lock it! And then re-check if someone has
> +			 * changed which z3fold page this handle points to
> +			 */
> +			if (lock)
> +				z3fold_page_lock(zhdr);
> +			preempt_enable();
> +			/*
> +			 * we use is_valid as a "cached" value: if it's false,
> +			 * no other checks needed, have to go one more round
> +			 */
> +		} while (!is_valid || (read_seqretry(&slots->seqlock, seq) &&
> +			(lock ? ({ z3fold_page_unlock(zhdr); 1; }) : 1)));
> +	} else {
> +		zhdr = (struct z3fold_header *)(handle & PAGE_MASK);
> +	}
> +
> +	return zhdr;
> +}
>
> ...
>
>  static unsigned short handle_to_chunks(unsigned long handle)
>  {
> -	unsigned long addr = *(unsigned long *)handle;
> +	unsigned long addr;
> +	struct z3fold_buddy_slots *slots = handle_to_slots(handle);
> +	unsigned int seq;
> +
> +	do {
> +		seq = read_seqbegin(&slots->seqlock);
> +		addr = *(unsigned long *)handle;
> +	} while (read_seqretry(&slots->seqlock, seq));

It isn't done here (I think).

