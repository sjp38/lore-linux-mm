Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D0DEC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E459620854
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:02:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E459620854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AF1D6B0007; Mon, 15 Apr 2019 22:02:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75F7C6B0008; Mon, 15 Apr 2019 22:02:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64E7D6B000A; Mon, 15 Apr 2019 22:02:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D42E6B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 22:02:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so13042134pfl.16
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 19:02:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q2g6FyKTC2YHWhfLzMGl5FgUmRBe+U0iSI4fZ42sI84=;
        b=HhCUEIzJcPRpxmeUEvE23EtTS+dwE0IxzBtUXu/iUkjbxgtWrMC+pgx/yUwzcmCdI0
         NdB5H312NejBMuNsONmWUFfWz7EXyZ7mPr44t0As2FKMDZQ0pVPLRnya2JzyNosaJO+V
         wYHgFzaCgMNaf0cAIGr0fAyFea8qstz+pMa/Ll2ZazK7q66ydBHUj8hke8k3e/+Nqjhi
         EOQYQzIIuLxpNQMAHF43zRj1iFhQ5I8PKXqZgK/06nuqM+mjGxYYZTYW8hguBPyDMbLI
         lKyB7UfOM3S8wzvuxDARspKZJ2Cta1oyOG2mugwrqextB1KaOOyf8RtymBPm3AgKM1yh
         V0fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWY89b83XWSs7mx6IaoVj9T71JggSdYxjqK2iiCjU9IT/Ldwy5I
	PBExz+JCn3fpK6LQ36Xyc1OdoIWu6qT0G+wUuh9Ew7bWwXIp270eMQumVBz9WL1uUOFqTTrlGed
	POSVoOTu88llFs4/85/bZTHTdnY6ecucp8s+uabGwNmYM4eoehQGzOwDKAw3isM8c+g==
X-Received: by 2002:a63:1a42:: with SMTP id a2mr70528178pgm.358.1555380135803;
        Mon, 15 Apr 2019 19:02:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSN4C5HygNDYjTOE38VVWZk7fkhUIeDjjc6qDTq/N14c+SH3MvXc/PppVBPF4l79qtokzo
X-Received: by 2002:a63:1a42:: with SMTP id a2mr70528118pgm.358.1555380135071;
        Mon, 15 Apr 2019 19:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555380135; cv=none;
        d=google.com; s=arc-20160816;
        b=Kj/2niuO209mgxupSXTRigq3LV7U/w41960iiOlLzm9HROqd0rcUQX4V5Oh2nBjxOO
         hIqk0pPwG0sor7KzW/6frx0d0iuKKOt/LhA+yMhaEFNf/EwIhzNExLY2EVwhEpl+OtMw
         nsuozX2VAClfqy7YiHR3SUrT+J1oY05773CAe/uJJmMYKDi71uoklttXWu+ioDOS2RPm
         hptnmdiOisF2YeIKDeqgRXvbpoMDsjDUOkyWGSBUX/LQPQNiDehc1claDD00a81P6CxP
         0Yjld79sHV+Yqef6+KA8t2eE37woK9AdGVaUhP0oAQ1gERHgY5Y2UKDzmcGT0rc7a8It
         /OZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Q2g6FyKTC2YHWhfLzMGl5FgUmRBe+U0iSI4fZ42sI84=;
        b=UxlaR/WL4DD4d/ZpFExZCg5W43wMh4C65/Q+yn8z5mtg1TRTVeRaHQiD2MAtlO/qRH
         65PPM7W30OtdCrC6Et13mZhcqApzF7Vp++qYC/vYj1cMnZzoc4YFz16Oo/n2LG40v210
         uhNnn2mhbZ9zUMQbgeAsVLaQFNNS+0rtKVP3Orey9ItSoPhGgn9gH+x8C5+5ICb9wZLm
         wTP1mB6biX/6z3VPPzfR1AlEd1K2F2JIwsDN+R4OMG9UmaO+DzQTMJq4tAOhIHUldOkC
         e/AvSkYVNSeA8x/fC/SkfLhtf1ZWIUZnrnXnY6y1u7dtYyXbt53iD2ClkmrGBrDDV9fZ
         Tc5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h11si38794877pgv.163.2019.04.15.19.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 19:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3DE82941;
	Tue, 16 Apr 2019 02:02:14 +0000 (UTC)
Date: Mon, 15 Apr 2019 19:02:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Potapenko <glider@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org,
 ndesaulniers@google.com, kcc@google.com, dvyukov@google.com,
 keescook@chromium.org, sspatil@android.com, labbott@redhat.com,
 kernel-hardening@lists.openwall.com
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
Message-Id: <20190415190213.5831bbc17e5073690713b001@linux-foundation.org>
In-Reply-To: <20190412124501.132678-1-glider@google.com>
References: <20190412124501.132678-1-glider@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Apr 2019 14:45:01 +0200 Alexander Potapenko <glider@google.com> wrote:

> This config option adds the possibility to initialize newly allocated
> pages and heap objects with zeroes.

At what cost?  Some performance test results would help this along.

> This is needed to prevent possible
> information leaks and make the control-flow bugs that depend on
> uninitialized values more deterministic.
> 
> Initialization is done at allocation time at the places where checks for
> __GFP_ZERO are performed. We don't initialize slab caches with
> constructors or SLAB_TYPESAFE_BY_RCU to preserve their semantics.
> 
> For kernel testing purposes filling allocations with a nonzero pattern
> would be more suitable, but may require platform-specific code. To have
> a simple baseline we've decided to start with zero-initialization.
> 
> No performance optimizations are done at the moment to reduce double
> initialization of memory regions.

Requiring a kernel rebuild is rather user-hostile.  A boot option
(early_param()) would be much more useful and I expect that the loss in
coverage would be small and acceptable?  Could possibly use the
static_branch infrastructure.

> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -167,6 +167,16 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
>  			      SLAB_TEMPORARY | \
>  			      SLAB_ACCOUNT)
>  
> +/*
> + * Do we need to initialize this allocation?
> + * Always true for __GFP_ZERO, CONFIG_INIT_HEAP_ALL enforces initialization
> + * of caches without constructors and RCU.
> + */
> +#define SLAB_WANT_INIT(cache, gfp_flags) \
> +	((GFP_INIT_ALWAYS_ON && !(cache)->ctor && \
> +	  !((cache)->flags & SLAB_TYPESAFE_BY_RCU)) || \
> +	 (gfp_flags & __GFP_ZERO))

Is there any reason why this *must* be implemented as a macro?  If not,
it should be written in C please.


