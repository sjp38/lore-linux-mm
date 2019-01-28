Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1820C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:04:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C47214DA
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:04:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C47214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8C5E8E0002; Mon, 28 Jan 2019 15:04:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E12B58E0001; Mon, 28 Jan 2019 15:04:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB5978E0002; Mon, 28 Jan 2019 15:04:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 870478E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:04:32 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a23so14918832pfo.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:04:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q07e/peENslT9pMfwiarlrwhYdvlmbA/0uPKfqvBYjo=;
        b=cUbq5uOgyMZBHxJWHzNHXZlJWkLXss7WR4EhBzenk8ciWG93IQ/DMwjoVdYd3r2tHh
         Am9EOfdIsXEGwNbvHxK05LO5dgSs5rDHlnP+qyDGFnLv5ObhkZQGeX1xxQd1J1UMVWdi
         VVgfqluXdMcV8fEcRb2EnvdKtctln+4EcbDL8zeQNQj9dral6WGAQyjyTKvbfkGSQg03
         gc3GD0ZTjF43pIQzcGrDIS8e+1sjJs3bWVEtQ8fh+E+A5ITNtANPSOiBgYByLiMB96Ta
         +nOc/8gPAyHWeA7ABIYmHjkNWbekttptpyq7yyV4nnt7xbnW9WdTZK0nZIRH8Onv4IFa
         KmOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukca2np6mUyyC+vCFkj7wTrPW5bB17vfQe3VzH/evobDHn1AK4Yq
	3JodemgILukaw3Trdf/VLDB+s6jq+BIUN3tCsFj9gJkXdNg99YBuhk6pc3uTbftsuyWYH67WFvS
	bUgA3y2HJGyKE4KLcaVDVEwkii8FxA8hxfpf+KM35R1qUtIPv6ETfzSaOkEtLcY+BNA==
X-Received: by 2002:a62:1a44:: with SMTP id a65mr23566755pfa.30.1548705872179;
        Mon, 28 Jan 2019 12:04:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7L2ysH6qvI1z3IOnLpVvLSS7NPn7/3Gln5RGZt8I+fuT59mwoAhxZCwlXWloxY6lObSNr+
X-Received: by 2002:a62:1a44:: with SMTP id a65mr23566714pfa.30.1548705871437;
        Mon, 28 Jan 2019 12:04:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548705871; cv=none;
        d=google.com; s=arc-20160816;
        b=gERwT3mqc7Cbymh+rj9ttRBGeTbLGkwCzCfhoNtaIVP5fLYgsAdD+lZ1jwBxd7/Fdy
         K+9P4V0NkBV61sR7IqBDZjldQHEWmGQebwKr5PdyhVb9qsVKQBBoTNQrRhRDdxp4h0Y1
         rhierLJ46ZMfCPjQGp2N/lY0Q+dTBX53ARNaX9gMeiVQn+gAhzZr7Odgq4wSGqwhEevk
         55E2Ltpc/wRvA7+Kc1qIryGi1CXfEGiHxMExPlo2fZG02K8at6io0d40tOjM246GjPse
         vgBkpWtHfmJSa1YWwyTkL45A1HE49Blnnpry6w8R8Jid+6EV6qhlLGBxlzBpXVa1Czyk
         jAhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Q07e/peENslT9pMfwiarlrwhYdvlmbA/0uPKfqvBYjo=;
        b=zvr+Y7e4ElcW1tVwq4ybGxMNTQ9UV/yz3HrRxOZN8SHTR+gCxbwZIJlqrQUAHpbsMz
         By4cgEOQy/ujbfBh/fQutRbedLgLY2C3ZkYotALvhBACx/engGRuy96c7gi/bHhrQktM
         SZofMRqUqT6UOuY8nHrNiXZQKISR8m6HEC9bPxN+d79Lwaop3xokuRheorWx6hcCg3J8
         Vb9jJ6ofgyp4GTZBoB2opMzRc0Eif7khfhUljhH6hTdrsoIjjQS5RWmr/htZFyqg+Geh
         +E/fIWJnKAC4pIVlS7ip2Z/l0g9jBmJ6wgEKO0Wudtn83O0hOpJVOOQkGDirk3tANnGY
         97tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d23si666749pgm.559.2019.01.28.12.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:04:31 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BC7C92477;
	Mon, 28 Jan 2019 20:04:30 +0000 (UTC)
Date: Mon, 28 Jan 2019 12:04:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier
 <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-Id: <20190128120429.17819bd348753c2d7ed3a7b9@linux-foundation.org>
In-Reply-To: <20190124115648.9433-3-urezki@gmail.com>
References: <20190124115648.9433-1-urezki@gmail.com>
	<20190124115648.9433-3-urezki@gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 12:56:48 +0100 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> commit 763b218ddfaf ("mm: add preempt points into
> __purge_vmap_area_lazy()")
> 
> introduced some preempt points, one of those is making an
> allocation more prioritized over lazy free of vmap areas.
> 
> Prioritizing an allocation over freeing does not work well
> all the time, i.e. it should be rather a compromise.
> 
> 1) Number of lazy pages directly influence on busy list length
> thus on operations like: allocation, lookup, unmap, remove, etc.
> 
> 2) Under heavy stress of vmalloc subsystem i run into a situation
> when memory usage gets increased hitting out_of_memory -> panic
> state due to completely blocking of logic that frees vmap areas
> in the __purge_vmap_area_lazy() function.
> 
> Establish a threshold passing which the freeing is prioritized
> back over allocation creating a balance between each other.

It would be useful to credit the vmalloc test driver for this
discovery, and perhaps to identify specifically which test triggered
the kernel misbehaviour.  Please send along suitable words and I'll add
them.


> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -661,23 +661,27 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  	struct llist_node *valist;
>  	struct vmap_area *va;
>  	struct vmap_area *n_va;
> -	bool do_free = false;
> +	int resched_threshold;
>  
>  	lockdep_assert_held(&vmap_purge_lock);
>  
>  	valist = llist_del_all(&vmap_purge_list);
> +	if (unlikely(valist == NULL))
> +		return false;

Why this change?

> +	/*
> +	 * TODO: to calculate a flush range without looping.
> +	 * The list can be up to lazy_max_pages() elements.
> +	 */

How important is this?

>  	llist_for_each_entry(va, valist, purge_list) {
>  		if (va->va_start < start)
>  			start = va->va_start;
>  		if (va->va_end > end)
>  			end = va->va_end;
> -		do_free = true;
>  	}
>  
> -	if (!do_free)
> -		return false;
> -
>  	flush_tlb_kernel_range(start, end);
> +	resched_threshold = (int) lazy_max_pages() << 1;

Is the typecast really needed?

Perhaps resched_threshold shiould have unsigned long type and perhaps
vmap_lazy_nr should be atomic_long_t?

>  	spin_lock(&vmap_area_lock);
>  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> @@ -685,7 +689,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  
>  		__free_vmap_area(va);
>  		atomic_sub(nr, &vmap_lazy_nr);
> -		cond_resched_lock(&vmap_area_lock);
> +
> +		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> +			cond_resched_lock(&vmap_area_lock);
>  	}
>  	spin_unlock(&vmap_area_lock);
>  	return true;

