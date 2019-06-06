Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A72C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0FD20866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:28:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W3f5O+mY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0FD20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85D3C6B026E; Wed,  5 Jun 2019 22:28:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80EB36B026F; Wed,  5 Jun 2019 22:28:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FDFA6B0270; Wed,  5 Jun 2019 22:28:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 387786B026E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 22:28:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m12so570100pls.10
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 19:28:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=vWAlFHQ/Rrwtr/A4rfYJEqxN6pUodZ8syzv7A3oUv4U=;
        b=gZ0g7GXIX6RRT/FJ6jGLTnZpJNNode8aLdDJdGZM2ouXm5I5NzjAbTn1hVYx68Zc6P
         Aj8wBWaYv05+VvHEqxbODLOUw7yBmSxLK6i6660hvwUUKm2k227bzKD9njaoggAZO5A6
         8Tinjmh2vRKwVjKj+kFikuvTKFi6t9nQGlbLpO5+mUPS+FIFcnvRypaNF6Xw+K4Z9JPH
         vRS2dyahGoNxatIH49VjzCNWG/wYNH6gRILFrmc1pouXcS4DUslivutHizNGkicDe7uL
         0m6OF5CQlKB/Z5awl56y+4wJx4oD72I67A8EWHF0SEbZWt5UgVIy1HK8jELzxHeJcgcg
         SoXw==
X-Gm-Message-State: APjAAAWTWNDpjgTO7+0NZg+vhH4kvy2GUUz4FBK7jtG9ybjaF40tryaK
	VZWTpiAiS/c4qqc+NuAVYqXJd5nEyEHwUoIYU1RCajtPAgZ8Dyoh9DXCx6pLOfIMIzIiSuJsIs0
	HEEegcTeU3vUJjJs/Nql41FEwNMwk8xl5Xnl0zy96q1bkuk4wgHHveBRttR86h4judw==
X-Received: by 2002:a63:295:: with SMTP id 143mr943107pgc.279.1559788089748;
        Wed, 05 Jun 2019 19:28:09 -0700 (PDT)
X-Received: by 2002:a63:295:: with SMTP id 143mr943037pgc.279.1559788088742;
        Wed, 05 Jun 2019 19:28:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559788088; cv=none;
        d=google.com; s=arc-20160816;
        b=qgoKvJRWFrM5HCZ84Lf0O8VcVT23bXkA3sYW4gA4rYD1v3ww0zH2NHlLW+/DPaJoza
         V/vEE3h96ZDlGlvNciiZk/tDOBWYPyuqFEiLVIiSgnISN2Qiu/F9DF3+zEysA1gx9RIi
         j0POagxwwWhlOcV+AlmCUkaGRFfPsUB0qiWVenPQiTktm16znBhbz9dpLstzT9A/GjMo
         tcyuOhgFoeb+Atb6MQjTF4u9sgBGRjhj9gYOXfde0xzj523zKwAenOFLtpPj0vY+F43r
         ELKpr4bVU8HOXyIvys90pLsac5gaFAJUcMYYi5ZQKDkeV8RnTHswK1VCJCk6WzUL5J8o
         jprA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=vWAlFHQ/Rrwtr/A4rfYJEqxN6pUodZ8syzv7A3oUv4U=;
        b=yspnz1RM1oi3pSJ0wg5Iag3REhRPRjVPBGbMyAK/jobmRJrw6W7gh4HTvqap9zoUVn
         ObGVdUhf3rZbpooQH2n+xDK+qSFetvPNdkClGsMviPbF0PvHr1oWGqYeCZ66Xu6VDzNX
         lzQ82hjcicimyPIppIqGWUh3Q+S/CO43uq7mn2lnRuOxRnwqFKtDDk1NomWZYb6Up24l
         Klq148sNmcCLbsEjBZBPDNhK+hxBQJKrtgt5baLnhsNM0PRP9o/8yFeVL01R12EZI8R5
         dZG00hCQtr+7NsB1YdlUvyPA72fxJBhYcJ2QIfztel7lsCVTka8fLPxh7GGlNOpxnhbw
         ORjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W3f5O+mY;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2sor616404pfm.28.2019.06.05.19.28.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 19:28:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W3f5O+mY;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=vWAlFHQ/Rrwtr/A4rfYJEqxN6pUodZ8syzv7A3oUv4U=;
        b=W3f5O+mYovybXZ0cWbChvth6/AY3jkzYaOlepyIP9hCfzq6OYLALpA+X9naH7Cze9A
         ggGtfZY7rD6baamWDhRmTjrHdAewf4yosvvRBEXcTizE9uOAW0S6B6wpjI+fm8sSO99o
         neyN+kj46xZ2iNO0Ag1ECTmBpA6EjmeUjRRLBRZxPzPlGv0DPGQPoPCPGyVt/OzGD+Jl
         aCkVtz5D24PwTMCpdbOUxseN9+MJ7cGDGPkFOAXEp8ukMlttTv+M6JmQ1UBphJM+oJbq
         gQ0PUNw+slBhhmOLsrIUocZn+vrCv/neMon1aDQpxxt8NMOEhg+T/CUiyTCTzJi9IPu3
         t/EA==
X-Google-Smtp-Source: APXvYqx3xvyhgYWL2BWoGcvR62aeVOfjNKcGFt+gjNY6c0YN6ruFIe+mrxqm/7JN3W/ANWl9JfROlw==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr970348pgi.7.1559788088441;
        Wed, 05 Jun 2019 19:28:08 -0700 (PDT)
Received: from localhost (193-116-78-124.tpgi.com.au. [193.116.78.124])
        by smtp.gmail.com with ESMTPSA id x28sm275357pfo.78.2019.06.05.19.28.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 19:28:07 -0700 (PDT)
Date: Thu, 06 Jun 2019 12:27:01 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/2] mm/large system hash: use vmalloc for size >
 MAX_ORDER when !hashdist
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds
	<torvalds@linux-foundation.org>
References: <20190605144814.29319-1-npiggin@gmail.com>
	<20190605142209.eb30cd883551a5bd81b09f00@linux-foundation.org>
In-Reply-To: <20190605142209.eb30cd883551a5bd81b09f00@linux-foundation.org>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1559787457.x4yxr4e2tw.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton's on June 6, 2019 7:22 am:
> On Thu,  6 Jun 2019 00:48:13 +1000 Nicholas Piggin <npiggin@gmail.com> wr=
ote:
>=20
>> The kernel currently clamps large system hashes to MAX_ORDER when
>> hashdist is not set, which is rather arbitrary.
>>=20
>> vmalloc space is limited on 32-bit machines, but this shouldn't
>> result in much more used because of small physical memory limiting
>> system hash sizes.
>>=20
>> Include "vmalloc" or "linear" in the kernel log message.
>>=20
>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> ---
>>=20
>> This is a better solution than the previous one for the case of !NUMA
>> systems running on CONFIG_NUMA kernels, we can clear the default
>> hashdist early and have everything allocated out of the linear map.
>>=20
>> The hugepage vmap series I will post later, but it's quite
>> independent from this improvement.
>>=20
>> ...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7966,6 +7966,7 @@ void *__init alloc_large_system_hash(const char *t=
ablename,
>>  	unsigned long log2qty, size;
>>  	void *table =3D NULL;
>>  	gfp_t gfp_flags;
>> +	bool virt;
>> =20
>>  	/* allow the kernel cmdline to have a say */
>>  	if (!numentries) {
>> @@ -8022,6 +8023,7 @@ void *__init alloc_large_system_hash(const char *t=
ablename,
>> =20
>>  	gfp_flags =3D (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOM=
IC;
>>  	do {
>> +		virt =3D false;
>>  		size =3D bucketsize << log2qty;
>>  		if (flags & HASH_EARLY) {
>>  			if (flags & HASH_ZERO)
>> @@ -8029,26 +8031,26 @@ void *__init alloc_large_system_hash(const char =
*tablename,
>>  			else
>>  				table =3D memblock_alloc_raw(size,
>>  							   SMP_CACHE_BYTES);
>> -		} else if (hashdist) {
>> +		} else if (get_order(size) >=3D MAX_ORDER || hashdist) {
>>  			table =3D __vmalloc(size, gfp_flags, PAGE_KERNEL);
>> +			virt =3D true;
>>  		} else {
>>  			/*
>>  			 * If bucketsize is not a power-of-two, we may free
>>  			 * some pages at the end of hash table which
>>  			 * alloc_pages_exact() automatically does
>>  			 */
>> -			if (get_order(size) < MAX_ORDER) {
>> -				table =3D alloc_pages_exact(size, gfp_flags);
>> -				kmemleak_alloc(table, size, 1, gfp_flags);
>> -			}
>> +			table =3D alloc_pages_exact(size, gfp_flags);
>> +			kmemleak_alloc(table, size, 1, gfp_flags);
>>  		}
>>  	} while (!table && size > PAGE_SIZE && --log2qty);
>> =20
>>  	if (!table)
>>  		panic("Failed to allocate %s hash table\n", tablename);
>> =20
>> -	pr_info("%s hash table entries: %ld (order: %d, %lu bytes)\n",
>> -		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size);
>> +	pr_info("%s hash table entries: %ld (order: %d, %lu bytes, %s)\n",
>> +		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size,
>> +		virt ? "vmalloc" : "linear");
>=20
> Could remove `bool virt' and use is_vmalloc_addr() in the printk?
>=20

It can run before mem_init() and it looks like some archs set
VMALLOC_START/END (high_memory) there (e.g., x86-32, ppc32).

Thanks,
Nick

=

