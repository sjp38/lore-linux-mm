Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E3EBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16C79218D9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:59:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16C79218D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E8AF8E0002; Wed, 13 Feb 2019 15:59:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798DD8E0001; Wed, 13 Feb 2019 15:59:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68B0C8E0002; Wed, 13 Feb 2019 15:59:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 263EA8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:59:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so2823112pfi.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:59:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YUOePfdqHbcThd0Mnm8bX3DeMs22ecKCTRdw9pfWjKI=;
        b=E1S8DOynxEiPv1GbahT92uuT2GUS5fj7Hb6lBUSo69octVURPjzXOUaQCQkVbYfkpJ
         f1eMkaPQIZXFOFv5bsvuT4nghvzDPpp+HxVhJcXbCWnU589L0CokZriehif5LeujjffZ
         mMtGnA9xrA2NxeCAltPKoeSIpvTq3nUrbki2A3KNcHksqA7TOWxloeLl9IvGVLXvpgHW
         1ZLgxP8FpsAseQ0LoKAE37oD+R5GQ4naBzZw+421rhQMVa2FEfXqYNt3skL8zqFUfh0y
         VUwbkp80eNQ51ok+/oVCL0eBMzoJ19GuUuIWwnWuFuH26OsoL26oG7s+efopK8IS5ela
         5WOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuadmT1kzp/UiKoWPGNPr3DyoPqIyMZ7wYVWy0Nxe6CxFJp8hMok
	QVxSBik2SK8gmNMBhg4UIOjUl7Neah3pjX/mka8hYyFlbTgnyyM24PitZ0lbuAZZ/FCaXLCYWOU
	ju9m7iPSvnueIZ8XzfHS5LJmr+UGj5pv3WAjvv0R+0Z33ZQIXc2yZPGCk0iVQhaII0w==
X-Received: by 2002:a17:902:241:: with SMTP id 59mr158944plc.72.1550091548700;
        Wed, 13 Feb 2019 12:59:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9YSlDUIW3TbjIkL2EjreRT4NZanUyVvVbzWeCdmIGiRNDGOt5z3A2VZw1PniKaAHQQNQZ
X-Received: by 2002:a17:902:241:: with SMTP id 59mr158896plc.72.1550091547987;
        Wed, 13 Feb 2019 12:59:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550091547; cv=none;
        d=google.com; s=arc-20160816;
        b=qD2bFVMJ7cLPyPCvIXFB3hskdvQ15cQL2A1fK7QJmVOg6H3n69nniM4d2y85OiiVrm
         5ZFD/tOn13CUSJHnRqxcUMntTZJVgz/5ULNk/HfyPU466Av7MS1NNSwcq0T6zO8hCBs8
         GVn1ZkMzLDYaDSy3hkH9P37jiD2gDsFFYN+YO0AO4wZy5aareAMwcwTBJFl90aJ3B0N7
         88Pg07zpYvePX9N9Kltt6u+B5SyU4GgJS6UGWtmJ/zWR0mIilJA1IWc0gnP1XewSEce4
         fCLIkoHLrAX+Hqzz1gulljFtZ1YFzAsj3QsA2N/KC5aqTEBTCA08Jv0XFxWxdTmOuwlU
         hM5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=YUOePfdqHbcThd0Mnm8bX3DeMs22ecKCTRdw9pfWjKI=;
        b=jopNsfUb8I4NQ0Xen8VGGpPZ1j0IBQ28NMsrHyXOY8ICmYQIzbcB2cHf2NeRKfW6eU
         PHjYjQjUhwiD6n92QO5Ds1XTZQW8rAKXJ0vd5GV3T8ZpOy/sPk6FFNYT5c3kmJ2YjM8k
         4igrH5nu7BV1tB2dJLC4ljBGOfTz41H/WMVg53aRwhcXovnNAvXUCSfZdwgrUs4BrLrz
         m7MCFHE4EsPCH62kNbY6KUqyEJfl/nBX4YBXa47GarT8oGh2UiNc7iBiLPbdVaRXk030
         tz5mpsfi8hYvdgh8w9avNgLAHORf03fqGbPcoNj3BBfCY4OIWPRLaSgO8NLd8hJYw+sM
         FkTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b9si309238plb.350.2019.02.13.12.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 12:59:07 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 17357121F;
	Wed, 13 Feb 2019 20:59:07 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:59:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jann Horn <jannh@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin
 <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mel
 Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>,
 netdev@vger.kernel.org, Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
Message-Id: <20190213125906.eae96c18fe585e060aaf0ef7@linux-foundation.org>
In-Reply-To: <20190213204157.12570-1-jannh@google.com>
References: <20190213204157.12570-1-jannh@google.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 21:41:57 +0100 Jann Horn <jannh@google.com> wrote:

> The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> number of references that we might need to create in the fastpath later,
> the bump-allocation fastpath only has to modify the non-atomic bias value
> that tracks the number of extra references we hold instead of the atomic
> refcount. The maximum number of allocations we can serve (under the
> assumption that no allocation is made with size 0) is nc->size, so that's
> the bias used.
> 
> However, even when all memory in the allocation has been given away, a
> reference to the page is still held; and in the `offset < 0` slowpath, the
> page may be reused if everyone else has dropped their references.
> This means that the necessary number of references is actually
> `nc->size+1`.
> 
> Luckily, from a quick grep, it looks like the only path that can call
> page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> requires CAP_NET_ADMIN in the init namespace and is only intended to be
> used for kernel testing and fuzzing.

For the net-naive, what is TAP?  It doesn't appear to mean
drivers/net/tap.c.

> To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> with a vector consisting of 15 elements containing 1 byte each.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>  		/* Even if we own the page, we do not use atomic_set().
>  		 * This would break get_page_unless_zero() users.
>  		 */
> -		page_ref_add(page, size - 1);
> +		page_ref_add(page, size);
>  
>  		/* reset page count bias and offset to start of new frag */
>  		nc->pfmemalloc = page_is_pfmemalloc(page);
> -		nc->pagecnt_bias = size;
> +		nc->pagecnt_bias = size + 1;
>  		nc->offset = size;
>  	}
>  
> @@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>  		size = nc->size;
>  #endif
>  		/* OK, page count is 0, we can safely set it */
> -		set_page_count(page, size);
> +		set_page_count(page, size + 1);
>  
>  		/* reset page count bias and offset to start of new frag */
> -		nc->pagecnt_bias = size;
> +		nc->pagecnt_bias = size + 1;
>  		offset = size - fragsz;
>  	}

This is probably more a davem patch than a -mm one.

