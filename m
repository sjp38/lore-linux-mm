Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC369C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A3BC216F4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NIM3ZNgr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A3BC216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0A66B0007; Wed, 22 May 2019 14:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D32C6B0008; Wed, 22 May 2019 14:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191626B000A; Wed, 22 May 2019 14:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D43B16B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 14:19:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x5so2272930pfi.5
        for <linux-mm@kvack.org>; Wed, 22 May 2019 11:19:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GoDXTtdm9kQ2YNX7cgiyZ3jw5SkNJQZFkD789d213x4=;
        b=HFtf/B3BtA4N94aiMRuaECr8VeeKsjP3IzbD1NUcl43SC2P6TKLCZG/iuNR/Tk47Jj
         4lOT5+8nRLSk4aN4wMxrF0U90vHy8RxIPmLw2fr4s8YX8mm8Vx2LNVLnvCYbBbYLcyJP
         YqRfOCzeHZJqZEUyGFiAR17pSxt72nEDO894izLQHim3wqmpJbxbjgmJ8X4+iVw7YfiW
         FuE22nxywqF300Atw9FKxjPEJ9evgqq/fdGsJEeJI2GWh6cC+AT7gEAAzpH6LLAHR8s9
         x0V8MkxqnWto+YVUV4PGHcd2p30yd3tghntkY0Mmz+Zi3NjZah8S5GNRFiFFLT0cEyrk
         IihQ==
X-Gm-Message-State: APjAAAV0bdmZDtEpE3Cm9FKgBnJXPDhIG8GlHovgetEiPQSUS/kwXFkb
	KKLO0rlUlZQ5AtMmwO0xvj2daPWXvj2LC8pYi8EJqGmtOO4gVL5VWOstdKVmpze3ll95BpGw/pn
	oK2iTX09msEcaPWgW+KyAOh3UjBcTnzLdbRs6JTMwrqWr7nUsmIDmVWP4aIYWepskjQ==
X-Received: by 2002:a62:6585:: with SMTP id z127mr57787788pfb.179.1558549146353;
        Wed, 22 May 2019 11:19:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl8GucOIaTTOnZ5gAwWmBOwrL3j84UHgu45VwfUvH74gk0ZUZz2aUCaqGnko+0+31QcRZQ
X-Received: by 2002:a62:6585:: with SMTP id z127mr57787705pfb.179.1558549145583;
        Wed, 22 May 2019 11:19:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558549145; cv=none;
        d=google.com; s=arc-20160816;
        b=dTy34/VnzUNIGmSaOilEX2YwdNVpxPdYgmO4JgeAaCGUAZKRm4c81rTBXRrhY8l7HQ
         y2MT7p6fcJp3mfQFvogyWxXY+TusTTAqCKnXzr2iQftA358n4Tt6jfXolwJZymb2V59f
         XYDMTmHK36TnBvD8OQGH9T0JNZepKIDNiXVAglTml5sVrlcjq86YSb5LIRuxytgg/cad
         OVNvsVKcTg8VgS150F7U3dLGFPraHpwB4gzNo+ucVpl/HMN9kDOykjgDGTQIJEjdrjrj
         MjersY+YvjIDYI/eBGWXLxo7imdt596XwW02DJnUaXaziBTle4L2WT0zMjAwWc/IX5cW
         2pjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GoDXTtdm9kQ2YNX7cgiyZ3jw5SkNJQZFkD789d213x4=;
        b=nVrvVjpShIfVRdOB+ZlfuJNYekrZBmJdzh15rG5uVdPq9SnruOASv9UkbWNwPHDwM6
         bot70uy3O5khGku0VUaSTdXPpODX0CeioLiBFHfhheJnaTWtuVsDI9hcYV3krtVEG66Z
         psgfn/+QOwOlHdaRTI5pY6aOpsvFCJypqtGhxyGFTZFDDZ11Tv8p53imorOQlAh33PTI
         gqK3OFtY54lS/Emut1+1/6QSCsXBKz90cYnCDGdKME993lxw5tXcG+Q/lZE0Nk6otIFy
         HcHICaJiKimA+SDO87ST+P3OHXrVZVfZgjlxDYge3ZOYDvA0WvYR6PpAwQjQP0eCusTC
         0b9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NIM3ZNgr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g137si17364304pfb.244.2019.05.22.11.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 11:19:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NIM3ZNgr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A77C120863;
	Wed, 22 May 2019 18:19:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558549145;
	bh=G3GMVM5Z9SEJ+DsCdXB8MywohW9z4T+H2D8ZFI7WiOI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=NIM3ZNgr+w+rANybmt+oWUqxREmEIjZmuZPGeUFjBHeJ7w2WDo2hbQsABkc/eX4VF
	 FLnuOBI4MeZ3d95cvcVGEF2S9XrPN72H76vec3v/5dMdmgNBkUgV3gGR4Ir1MBp9jb
	 tGHk7S/jd3PxckYwQMqdxg7xd/FbKlkpc1BYAfvY=
Date: Wed, 22 May 2019 11:19:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Message-Id: <20190522111904.ff2cd5011c8c3b3207e3f3fa@linux-foundation.org>
In-Reply-To: <20190522150939.24605-2-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
	<20190522150939.24605-2-urezki@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 17:09:37 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> Introduce ne_fit_preload()/ne_fit_preload_end() functions
> for preloading one extra vmap_area object to ensure that
> we have it available when fit type is NE_FIT_TYPE.
> 
> The preload is done per CPU and with GFP_KERNEL permissive
> allocation masks, which allow to be more stable under low
> memory condition and high memory pressure.

What is the reason for this change?  Presumably some workload is
suffering from allocation failures?  Please provide a full description
of when and how this occurs so others can judge the desirability of
this change.

> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -364,6 +364,13 @@ static LIST_HEAD(free_vmap_area_list);
>   */
>  static struct rb_root free_vmap_area_root = RB_ROOT;
>  
> +/*
> + * Preload a CPU with one object for "no edge" split case. The
> + * aim is to get rid of allocations from the atomic context, thus
> + * to use more permissive allocation masks.
> + */
> +static DEFINE_PER_CPU(struct vmap_area *, ne_fit_preload_node);
> +
>  static __always_inline unsigned long
>  va_size(struct vmap_area *va)
>  {
> @@ -950,9 +957,24 @@ adjust_va_to_fit_type(struct vmap_area *va,
>  		 *   L V  NVA  V R
>  		 * |---|-------|---|
>  		 */
> -		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> -		if (unlikely(!lva))
> -			return -1;
> +		lva = __this_cpu_xchg(ne_fit_preload_node, NULL);
> +		if (unlikely(!lva)) {
> +			/*
> +			 * For percpu allocator we do not do any pre-allocation
> +			 * and leave it as it is. The reason is it most likely
> +			 * never ends up with NE_FIT_TYPE splitting. In case of
> +			 * percpu allocations offsets and sizes are aligned to
> +			 * fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE
> +			 * are its main fitting cases.
> +			 *
> +			 * There are few exceptions though, as en example it is

"a few"

s/en/an/

> +			 * a first allocation(early boot up) when we have "one"

s/(/ (/

> +			 * big free space that has to be split.
> +			 */
> +			lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> +			if (!lva)
> +				return -1;
> +		}
>  
>  		/*
>  		 * Build the remainder.
> @@ -1023,6 +1045,50 @@ __alloc_vmap_area(unsigned long size, unsigned long align,
>  }
>  
>  /*
> + * Preload this CPU with one extra vmap_area object to ensure
> + * that we have it available when fit type of free area is
> + * NE_FIT_TYPE.
> + *
> + * The preload is done in non-atomic context thus, it allows us

s/ thus,/, thus/

> + * to use more permissive allocation masks, therefore to be more

s/, therefore//

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

Why not make it do `return preloaded;'?  The
pass-and-return-by-reference seems unnecessary?

Otherwise it all appears solid and sensible.

