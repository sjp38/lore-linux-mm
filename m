Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 462CBC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:33:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0E1921773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:33:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E1921773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37FE56B0006; Fri, 24 May 2019 06:33:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 330966B0008; Fri, 24 May 2019 06:33:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 220666B000A; Fri, 24 May 2019 06:33:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01FCF6B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:33:32 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id h133so2561984ith.9
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I53DuanS95v7fHuMYQvlJpeT9Wl3GNxP130b7kULouw=;
        b=Wa606KXaFzV8mvCvnsGScrPl4fccOBCBkLU+Zhd95Fulu9YKPFNkg2pHX6PTvHK9Ym
         doXCeKMUqWpLdD521Gf8ETmrfzwNvkerZucp+CO4F0xILWBeyvbGEPjH7hA4ssokKmhZ
         W2DAQkZbzLfnMZ58A2RPhRaz+619qBamTOt0FTH7XL1WrR7khXmsfguhqvphHXakfQye
         bTxmxZbX7qdDNfHNBDmlYhPcLeW0krY9gz/ijGdk1ui7m+HQRG3RHllQbbt/SeB+eWEE
         tbIElRMOuOOtIo+MTtNQkoa3aZCbxr020PoYesR6buvq8sKBIBs+TEEHV25tvc6IKDB1
         b/xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXYHUtWPOJYtOpQvkh8CIe1NSl8+nBGUSXQBHfSQihDWlTF7p6b
	TEecqNIQie61RXDHg3aPTi2SafcbclwkXLhltk+tQnHNjaO7f0M0SCvdXxTMwAP6Y5xPvO9Hjoq
	xrBJ8IaXUh7MC/ALWVFasZn02EvwpuFwiOSE255sLnBn3DyJwXy3Ei8kDnoz/JH9New==
X-Received: by 2002:a24:93:: with SMTP id 141mr19203168ita.175.1558694011741;
        Fri, 24 May 2019 03:33:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6ZDKXRLr4YPJUCXYO91NfNZZ0DdecmxVQR3vl9MWMCvdbH5neY6/UmEXXORK01SbaN3FL
X-Received: by 2002:a24:93:: with SMTP id 141mr19203106ita.175.1558694010935;
        Fri, 24 May 2019 03:33:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558694010; cv=none;
        d=google.com; s=arc-20160816;
        b=EccYMyI2zOvihS133dSdkD/kIh5oGIM2y6TV2bQvjj2MeKX4f9KKy3FHxtE0NqYBA4
         49HY34803Gyc6pSs56N7P1mBQbH0gHv5uifvef9OuH7V+RlkrnXEirg2/xTXcTIHmBg6
         tMQC4cxqQX8Sp/f3fm608NNoVKCp4IMctAW26e61bLf3O93ReRESXedNrA031hZV9pui
         gD8ZUO28EoS1CBf9GBLFRD6vgqdXPRcyxRbKuF9VUf/Kh7spwwsrMscnMhihgZFXFO0R
         ukGets1wJmX54qPUg23Qzy53mVE8yp3e5dfC0HdHJ4erljXNA7Yq1tCilx3+A+iaLvsj
         IwWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I53DuanS95v7fHuMYQvlJpeT9Wl3GNxP130b7kULouw=;
        b=qoy8ISp9wu9wbZke5Ba84N1NXLy0GvoRn5HyR3w8aolRMTo2j2zInoJB6amKW3PPT4
         mry8y9ZDZaDXNquqmG6zpQVvFPD3aqOoS6dmwkOt9DOGmcyrB3Pzc5HGo4NAQBKSwjFU
         1SVGtpu4w84lBnERjrKAOZEFGM1K8FWp+FqawTsIkHNxBcDDTffg07ESP7YG3NQRCS+x
         Q0WwWD5YT7fSOvhUN1q0SelbfUNfA0+d6qT3ZVbrfIQWQu+DOYWq0Fj2hZVPJdJ+smx6
         oY6zukCjgJrYBBqaMG2k13lHxBAbJ8Hhes2p+6uAXi5t465jVG8pzUlJLNgvd1RKAXBf
         eHWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id f7si1467308iob.56.2019.05.24.03.33.29
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 03:33:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.253.229.186])
	by sina.com with ESMTP
	id 5CE7C87500007F1A; Fri, 24 May 2019 18:33:28 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 116792393274
From: Hillf Danton <hdanton@sina.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Hillf Danton <hdanton@sina.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/4] mm/vmap: preload a CPU with one object for split purpose
Date: Fri, 24 May 2019 18:33:16 +0800
Message-Id: <20190524103316.1352-1-hdanton@sina.com>
In-Reply-To: <20190522150939.24605-1-urezki@gmail.com>
References: 
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 22 May 2019 17:09:37 +0200 Uladzislau Rezki (Sony) wrote:
>  /*
> + * Preload this CPU with one extra vmap_area object to ensure
> + * that we have it available when fit type of free area is
> + * NE_FIT_TYPE.
> + *
> + * The preload is done in non-atomic context thus, it allows us
> + * to use more permissive allocation masks, therefore to be more
> + * stable under low memory condition and high memory pressure.
> + *
> + * If success, it returns zero with preemption disabled. In case
> + * of error, (-ENOMEM) is returned with preemption not disabled.
> + * Note it has to be paired with alloc_vmap_area_preload_end().
> + */
> +static void
> +ne_fit_preload(int *preloaded)
> +{
> +	preempt_disable();
> +
> +	if (!__this_cpu_read(ne_fit_preload_node)) {
> +		struct vmap_area *node;
> +
> +		preempt_enable();
> +		node = kmem_cache_alloc(vmap_area_cachep, GFP_KERNEL);

Alternatively, can you please take another look at the upside to use
the memory node parameter in alloc_vmap_area() for allocating va slab,
given that this preload, unlike adjust_va_to_fit_type() is invoked
with the vmap_area_lock not aquired?

> +		if (node == NULL) {
> +			*preloaded = 0;
> +			return;
> +		}
> +
> +		preempt_disable();
> +
> +		if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
> +			kmem_cache_free(vmap_area_cachep, node);
> +	}
> +
> +	*preloaded = 1;
> +}
> +
> +static void
> +ne_fit_preload_end(int preloaded)
> +{
> +	if (preloaded)
> +		preempt_enable();
> +}
> +
> +/*
>   * Allocate a region of KVA of the specified size and alignment, within the
>   * vstart and vend.
>   */
> @@ -1034,6 +1100,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	struct vmap_area *va;
>  	unsigned long addr;
>  	int purged = 0;
> +	int preloaded;
>  
>  	BUG_ON(!size);
>  	BUG_ON(offset_in_page(size));
> @@ -1056,6 +1123,12 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
>  
>  retry:
> +	/*
> +	 * Even if it fails we do not really care about that.
> +	 * Just proceed as it is. "overflow" path will refill
> +	 * the cache we allocate from.
> +	 */
> +	ne_fit_preload(&preloaded);
>  	spin_lock(&vmap_area_lock);
>  
>  	/*
> @@ -1063,6 +1136,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	 * returned. Therefore trigger the overflow path.
>  	 */
>  	addr = __alloc_vmap_area(size, align, vstart, vend);
> +	ne_fit_preload_end(preloaded);
> +
>  	if (unlikely(addr == vend))
>  		goto overflow;
>  
> -- 
> 2.11.0
>  
Best Regards
Hillf

