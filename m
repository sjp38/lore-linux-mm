Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0443C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:43:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E9852084E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:43:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Cl0ix3sG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E9852084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19DB78E012D; Mon, 11 Feb 2019 21:43:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1264A8E0115; Mon, 11 Feb 2019 21:43:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2FFE8E012D; Mon, 11 Feb 2019 21:43:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C65C58E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:43:38 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d13so1250619qth.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:43:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fMMnULhmx6tn2dppUHwiG4kSEpOaNmlUUmhgOn7rBY8=;
        b=R2uKWggMkYtO2klFWjl2xaTo/YpnMmgbnPRGRZG0edpWDwn4KkfsALusK7oBJpwXG3
         VD8sVzNumDKIzqaPAEf69XF8jwkqbEX8RHs89P4z9TnDLpoFevlteaBJ6HKLga426F1a
         lQbK+LY6dIYYmSenlKZTqLYIWgZVTF9D2BKb4vSEtzbzrcoLnAZJ8md+fCFULMpeL+Xw
         lHEBh31xKE+++QPbCEg2g3p4QShF/feykHP0JGOdsIMiI5yynzqeFqA5Gc4wIoift4Nc
         Og9BhiaHNRp8MSiHzukX1pHghS3FURJH9FH8U+uHsSUtXadpm4MjkZX2Oht1JuhqPNHp
         qAFQ==
X-Gm-Message-State: AHQUAuaBYBueL2OpR+6dXps2EMXEwfd4DCjfaJNbbTomn6fGcxAGQCsV
	d/RVbgSVyQdG3zeoxdakh8wOjqc3UItkZvobvoMY+Z84Y/odoawje89n2c9/Uk85rfjmdE/0ZXL
	6Aa20P8R3YUNqI+Rb54rZ51J/xo6YbdYPPLAQnKwIb01kkS03I11f9v56dB1JLoh1JjZjoJPgyE
	HL19jY0wZJzgheO5O6wHSQiM2b4Kqu2ez/xXOcKZ5Tmnk2bXBvSfVB4GwJq3c7dJaegIOa4xn7x
	GZrrgHMQb1EEi4xUF2b+R7pcfGKK/4O1UQuSBM547tnJ4rM2hmYEqSwQdKb1gZCHif6OOjtF3bY
	yO6001V1oKzwh3/xlU4seJnRnrChjYlgE/d9b7AiuLbtu8yKhjNpZhNSnRvt+0bKyHvQsvLBBgq
	0
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr1102882qta.382.1549939418514;
        Mon, 11 Feb 2019 18:43:38 -0800 (PST)
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr1102845qta.382.1549939417664;
        Mon, 11 Feb 2019 18:43:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549939417; cv=none;
        d=google.com; s=arc-20160816;
        b=Hb0MZgjbvlqoS8//VV8aG9EkdLd8mbOA9CU/7fwOKTT9v6Jl2AUDpyJAN1i5YgryDX
         vZANRQcd3VWFRW0KqRdeBnvtAsBTt5/myJ3GrOQLmgrgO+DATywFPy44ndDLu06HIvRy
         NTcpDAUtVvIykZWc88zq0PT1Ewry5mAi5oVdxOoj8inzzhSD6Ut+9HQKTJXQB/NfpgRF
         eVoGuLU8wIiF6JB5Li77UqraCBL3z83fCeNr9GWOaeETZabe7sAZ6dcpkQ3xi3RKvcjD
         NjGeXsogOBX1WuOWrnuBMiOtfwJmN1foQQX09klQBjTeUaUHq1ktCL8VIgrmAb9D2fso
         4Vyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=fMMnULhmx6tn2dppUHwiG4kSEpOaNmlUUmhgOn7rBY8=;
        b=z8lEgwD86cPCVmr8btn2IHkZmBZjs3y755i5bjRWpWa+69+JttaA3YmA4o0+26gNvy
         ytyBk8phlYg2VFA7byPdr53Fx9hVAIRgjKgK4lR6L5nl5G7NnhjUXDn31276cDDFN8or
         CD5iEL+kPVBC3R76xD96ojzerVZANN1VyAFLeFguiqQXFmIISBFeBm6VHpcZXCax/P5u
         BB/mVG9tzSmTFqrtHNbTjwRc9K3l22yYh+IFE0A82Ti2rlaEzZC+aviOjjg/4gmT4JQT
         u0n/bwfGpQ+4ni8jh3AatAREqyr2AwE9UbM4VdqvrQ/gRialZ4fTaxQCfD5EITHnlPX3
         Mm3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Cl0ix3sG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x15sor14437438qth.54.2019.02.11.18.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 18:43:37 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Cl0ix3sG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=fMMnULhmx6tn2dppUHwiG4kSEpOaNmlUUmhgOn7rBY8=;
        b=Cl0ix3sG5kTob+8hhLtiOGpQ+CyVyDng42OCiDG9I4vYVxFqu8OMLKfalBiWCSZCVd
         GQRkn4Fl8KTkhaJ6LbRveheE8sGvmvz78RgzHwPfnp89AHqGv1acqET514HzC5MFgmXU
         42WvDu0uBnlYG6dtRT7Yq9pIR+mq+vcaAuQIfxplB+/7Ye+9rU0fSa+2476J6wyrg88z
         f3/Dy8XjHLld7fbG45UVghRP+KYU0jbkSYMwTyYZO2LwxSud8RrEzOj3nqSSCawAAkk9
         nZpZlrUkhcZpZoWdDs3qJXklgqufcDF+aZTMcc0eCvlGL5aaxCHxtttMB/kOcdj1rV61
         xlVA==
X-Google-Smtp-Source: AHgI3IbOYkfnYlf/Y8+u8gfDWmXOXoADkCMMKrvqQdPv6PpshzLARGd5kPuntT/oyaOMLLWVrtFM2w==
X-Received: by 2002:ac8:2d85:: with SMTP id p5mr1132224qta.136.1549939417280;
        Mon, 11 Feb 2019 18:43:37 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q53sm13887015qte.22.2019.02.11.18.43.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:43:36 -0800 (PST)
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with
 CONFIG_SLAB_FREELIST_HARDENED
To: Andrey Konovalov <andreyknvl@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
Date: Mon, 11 Feb 2019 21:43:35 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/11/19 4:59 PM, Andrey Konovalov wrote:
> CONFIG_SLAB_FREELIST_HARDENED hashes freelist pointer with the address
> of the object where the pointer gets stored. With tag based KASAN we don't
> account for that when building freelist, as we call set_freepointer() with
> the first argument untagged. This patch changes the code to properly
> propagate tags throughout the loop.
> 
> Reported-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/slub.c | 20 +++++++-------------
>  1 file changed, 7 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index ce874a5c9ee7..0d32f8d30752 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -303,11 +303,6 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
>  		__p < (__addr) + (__objects) * (__s)->size; \
>  		__p += (__s)->size)
>  
> -#define for_each_object_idx(__p, __idx, __s, __addr, __objects) \
> -	for (__p = fixup_red_left(__s, __addr), __idx = 1; \
> -		__idx <= __objects; \
> -		__p += (__s)->size, __idx++)
> -
>  /* Determine object index from a given position */
>  static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
>  {
> @@ -1655,17 +1650,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	shuffle = shuffle_freelist(s, page);
>  
>  	if (!shuffle) {
> -		for_each_object_idx(p, idx, s, start, page->objects) {
> -			if (likely(idx < page->objects)) {
> -				next = p + s->size;
> -				next = setup_object(s, page, next);
> -				set_freepointer(s, p, next);
> -			} else
> -				set_freepointer(s, p, NULL);
> -		}
>  		start = fixup_red_left(s, start);
>  		start = setup_object(s, page, start);
>  		page->freelist = start;
> +		for (idx = 0, p = start; idx < page->objects - 1; idx++) {
> +			next = p + s->size;
> +			next = setup_object(s, page, next);
> +			set_freepointer(s, p, next);
> +			p = next;
> +		}
> +		set_freepointer(s, p, NULL);
>  	}
>  
>  	page->inuse = page->objects;
> 

Well, this one patch does not work here, as it throws endless errors below
during boot. Still need this patch to fix it.

https://marc.info/?l=linux-mm&m=154955366113951&w=2

[   85.744772] BUG kmemleak_object (Tainted: G    B        L   ): Freepointer
corrupt
[   85.744776]
-----------------------------------------------------------------------------
[   85.744776]
[   85.744788] INFO: Allocated in create_object+0x88/0x9c8 age=2564 cpu=153 pid=1
[   85.744797] 	kmem_cache_alloc+0x39c/0x4ec
[   85.744803] 	create_object+0x88/0x9c8
[   85.744811] 	kmemleak_alloc+0xbc/0x180
[   85.744818] 	kmem_cache_alloc+0x3ec/0x4ec
[   85.744825] 	acpi_ut_create_generic_state+0x64/0xc4
[   85.744832] 	acpi_ut_create_pkg_state+0x24/0x1c8
[   85.744840] 	acpi_ut_walk_package_tree+0x268/0x564
[   85.744848] 	acpi_ns_init_one_package+0x80/0x114
[   85.744856] 	acpi_ns_init_one_object+0x214/0x3d8
[   85.744862] 	acpi_ns_walk_namespace+0x288/0x384
[   85.744869] 	acpi_walk_namespace+0xac/0xe8
[   85.744877] 	acpi_ns_initialize_objects+0x50/0x98
[   85.744883] 	acpi_load_tables+0xac/0x120
[   85.744891] 	acpi_init+0x128/0x850
[   85.744898] 	do_one_initcall+0x3ac/0x8c0
[   85.744906] 	kernel_init_freeable+0xcdc/0x1104
[   85.744916] INFO: Freed in free_object_rcu+0x200/0x228 age=3 cpu=153 pid=0
[   85.744923] 	free_object_rcu+0x200/0x228
[   85.744931] 	rcu_process_callbacks+0xb00/0x12c0
[   85.744937] 	__do_softirq+0x644/0xfd0
[   85.744944] 	irq_exit+0x29c/0x370
[   85.744952] 	__handle_domain_irq+0xe0/0x1c4
[   85.744958] 	gic_handle_irq+0x1c4/0x3b0
[   85.744964] 	el1_irq+0xb0/0x140
[   85.744971] 	arch_cpu_idle+0x26c/0x594
[   85.744978] 	default_idle_call+0x44/0x5c
[   85.744985] 	do_idle+0x180/0x260
[   85.744993] 	cpu_startup_entry+0x24/0x28
[   85.745001] 	secondary_start_kernel+0x36c/0x440
[   85.745009] INFO: Slab 0x(____ptrval____) objects=91 used=0
fp=0x(____ptrval____) flags=0x17ffffffc000200
[   85.745015] INFO: Object 0x(____ptrval____) @offset=35296 fp=0x(____ptrval____)

kkkkk4.226750] Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[   84.22[   84.226765] ORedzone (____ptrptrval____): 5a worker/223:0 Tainted: G
   B        L    5.0.0-rc6+ #36
[   84.226790] Hardware name: HPE Apollo 70             /C01_APACHE_MB         ,
BIOS L50_5.13_1.0.6 07/10/2018
[   84.226798] Workqueue: events free_obj_work
[   84.226802] Call trace:
[   84.226809]  dump_backtrace+0x0/0x450
[   84.226815]  show_stack+0x20/0x2c
[   84.226822]  __dump_stack+0x20/0x28
[   84.226828]  dump_stack+0xa0/0xfc
[   84.226835]  print_trailer+0x1a8/0x1bc
[   84.226842]  object_err+0x40/0x50
[   84.226848]  check_object+0x214/0x2b8
[   84.226854]  __free_slab+0x9c/0x31c
[   84.226860]  discard_slab+0x78/0xa8
[   84.226866]  kmem_cache_free+0x99c/0x9f0
[   84.226873]  free_obj_work+0x92c/0xa44
[   84.226879]  process_one_work+0x894/0x1280
[   84.226885]  worker_thread+0x684/0xa1c
[   84.226892]  kthread+0x2cc/0x2e8
[   84.226898]  ret_from_fork+0x10/0x18
[   84.229197]

