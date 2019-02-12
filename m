Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE59AC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:12:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7176B222B1
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:12:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7176B222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9278E0002; Tue, 12 Feb 2019 16:12:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 057BB8E0001; Tue, 12 Feb 2019 16:12:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3B3A8E0002; Tue, 12 Feb 2019 16:12:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEEB8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:12:53 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so111651pgk.2
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:12:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IEdcggLtMD6ri/3ODdsLrF3TOuycQjedMbdh3Bz2yeg=;
        b=G/bVwXv5+zlzdefbkWeGKPvptSq0AA02JII7fUm+oCYHzZzXACcUfJMSiJRHqpmncj
         DSvYs3cA1CmQUn+VDPWZKWIKQujhRR6pfNDIT5ZNWdB+EFjEVLvlxgDmjPjTi7rJxWYE
         wo8qbwyrJs5/rMtKiN14+QkKt0p3uoHvMBwW+XJDpd3Ed56di8MYS2YLlRWsXxjYafVK
         Zq0mRbPZBIaI0DCML7IfVzY6FI+zPSOUxBsQb8hFKPIGMCfkKn6X5vdVnXaKr/Xno2AF
         Od+t3khmTqecr7sgqrqeVKuQYgQhMezy4Unq7hRG5i+eyM0iZrQBZNLil60ds6y7mIV6
         D79w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZi42QWg8XmprhpggP1bH92dtPIHBi8qI08x0nV2OdHSaScbhaI
	MuvkK4Y6AeRQPqGWXk5DTkMJ/rqOGM36cfSk6M0pz1EJdVl98vyXRoquLIiT3+e/XOmimd+MOEU
	zm5Vi0mrquuDy4HhbgFXsNkyM700STE0qv7NbyasjhhAH+n8vnmWEycl6rHLLSJZ5fQ==
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr5985568plo.194.1550005973328;
        Tue, 12 Feb 2019 13:12:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0e7Ab20yYB9Bcj4JLcNKsPKSlOsV2pROx1K256HtRdKgx+/AwoqU1bMowNNDf0lX80p2U
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr5985513plo.194.1550005972667;
        Tue, 12 Feb 2019 13:12:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550005972; cv=none;
        d=google.com; s=arc-20160816;
        b=T51E9JhB0sxD0oHWroElO86HT6ol9Fg9B0roilg8mRhY01sFEB5krLh55lfSej9A8K
         I9hDK7wktPuXOAgLvXk7zsHYgLf3YGB8aaluAQcsObT71gYDX7BAZNeAfKKYyuBgx4U6
         LXoFn6bGvHoqJDcxGc8l9NBWI3Hiu6fRhIGNZL9zrJ9DxTJ2uDzDPE11tMdhDzJTVuDP
         IEo7n7CpXUXidsdrGktwbAAbK7QwxPRwmtaQyOyThc0/P5drXztnEv+WGn4hu8v+H9fs
         aQ9Q3yFNewdiz45bp8p7cEjBfCFQ4bbEcoTH1eVJnZ/cKtKnc6IAa5iEK6vKHzgs14FM
         zMOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IEdcggLtMD6ri/3ODdsLrF3TOuycQjedMbdh3Bz2yeg=;
        b=p0xm2jeQMm4hyJpS+cAZiKAML54wydz6UsWdqRhtukmoQBavCkV1n9zMHZdB4Lcrti
         3X67ci29xF+dh2OcUN7iLzohVNjSMmquFaDkZC4ogNz55fOlt8bsJ3f6n5mnC4bwsc6P
         oOlvak7eUfrmSSr2BQLDmxsmDnNYk9ACu11v0gwwqlAvSoFIwHuq7d5FIFiEBf04QJ3D
         VgQZPp+gW9Ca/qdw9boUUGq2SeJAMgeUUFdsgeuEWFgdRnJIBSpg49jFX0DD/cvVUmyH
         R9+zBxOjl9ll3PI/hTluPuHWBPyCOCHXRKNr6SFLxMMjv0LQCQriJPg6UaaBsefduFRR
         16wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b6si7333599pgm.216.2019.02.12.13.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 13:12:52 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B7725E5FA;
	Tue, 12 Feb 2019 21:12:51 +0000 (UTC)
Date: Tue, 12 Feb 2019 13:12:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
 <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>
Subject: Re: [PATCH 4/5] kasan, slub: move kasan_poison_slab hook before
 page_address
Message-Id: <20190212131250.0f98d6a9cea8e03ca47f980c@linux-foundation.org>
In-Reply-To: <cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
	<cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 22:59:53 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:

> With tag based KASAN page_address() looks at the page flags to see
> whether the resulting pointer needs to have a tag set. Since we don't
> want to set a tag when page_address() is called on SLAB pages, we call
> page_kasan_tag_reset() in kasan_poison_slab(). However in allocate_slab()
> page_address() is called before kasan_poison_slab(). Fix it by changing
> the order.
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1642,12 +1642,15 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	if (page_is_pfmemalloc(page))
>  		SetPageSlabPfmemalloc(page);
>  
> +	kasan_poison_slab(page);
> +
>  	start = page_address(page);
>  
> -	if (unlikely(s->flags & SLAB_POISON))
> +	if (unlikely(s->flags & SLAB_POISON)) {
> +		metadata_access_enable();
>  		memset(start, POISON_INUSE, PAGE_SIZE << order);
> -
> -	kasan_poison_slab(page);
> +		metadata_access_disable();
> +	}
>  
>  	shuffle = shuffle_freelist(s, page);

This doesn't compile when CONFIG_SLUB_DEBUG=n.  Please review carefully:

--- a/mm/slub.c~kasan-slub-move-kasan_poison_slab-hook-before-page_address-fix
+++ a/mm/slub.c
@@ -1357,6 +1357,14 @@ slab_flags_t kmem_cache_flags(unsigned i
 
 #define disable_higher_order_debug 0
 
+static inline void metadata_access_enable(void)
+{
+}
+
+static inline void metadata_access_disable(void)
+{
+}
+
 static inline unsigned long slabs_node(struct kmem_cache *s, int node)
 							{ return 0; }
 static inline unsigned long node_nr_slabs(struct kmem_cache_node *n)
_

