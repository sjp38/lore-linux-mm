Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA0AAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9771720700
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="a1WHWnai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9771720700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28D206B0003; Wed, 27 Mar 2019 07:34:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D156B0006; Wed, 27 Mar 2019 07:34:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 151C26B0007; Wed, 27 Mar 2019 07:34:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA4BF6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:34:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q12so16588865qtr.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:34:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oKXYvkzbAHnLf4Q/hIMN6pMELkeRbB1zoPMlVpolYQU=;
        b=Wb4XbP87av2zPA6mdxcztgjWL2vE26AyMgGHRnGe8BUUy+pk2qvl1b8yVNCfRTlFIA
         Je4jTlm6Vu/s/xr0T/nSJmFboBWPVtPQoHpEuwf5JORqYbLV6pbcSuCChl4Kxiiqs4FU
         46EtJ4XJgXxcJaVfPYLFZdiW61O58rmY670oZSjHG8Gxzt9jBAlzyDuvg4JMAMAHe9G8
         2ePxHvNRlewOYkW4zmdJ3c+DSFSBeGq2h4B9UjNKYycKfHN8SU2IVJHv2MsBgcTT2V3D
         O8d/8SaZEsmTq6tXwCoTyp8nE7sWprCi1Pa17rRrQAJHELlRo3LRlun9/5FfWLKm4fGP
         9I4w==
X-Gm-Message-State: APjAAAWJlJfdApr7Bxg3e7H2Zd3abRTbdC3FLxqM1BoSRm3vGeyeQKDX
	ZInSJUGd7KUshZj6u6vZ3sbggL48s19VqeQZjE1lgtHlAZy2+HI0U68jxEzEtcIWvRcpNNU6u+i
	6Bo412lmDFoRArT1qiLQQ8xdS9xu0zmUBGXICmA2wvBSkzlZF5x5zkig04vDoKS1nBQ==
X-Received: by 2002:a37:7d86:: with SMTP id y128mr28958663qkc.36.1553686474665;
        Wed, 27 Mar 2019 04:34:34 -0700 (PDT)
X-Received: by 2002:a37:7d86:: with SMTP id y128mr28958617qkc.36.1553686474005;
        Wed, 27 Mar 2019 04:34:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553686474; cv=none;
        d=google.com; s=arc-20160816;
        b=l7nGEc8B9oO1I02c/6zceiLIem7W5AUwxgf84elx9wmsnsYz/YFlZhRXX6ctNbKo7F
         yNA81Y8iDifN1Lx6QOriYTZy85CfpThMb6P+RO6aV3lbB7W4Bu3LqyGDVuwxLbrzcxp6
         6ZnO9oPrGBrIg7tgR6tX5qO1EokWpMWzM4lzjlvpFNgNYxLYYmi5/Dm9qdlDz5yQ1Zlj
         CPEu0IyLl1txIZpbz6rW9AQvxVeMVcEdqGQNNmrvTHZ/1q0KNdjw+FZILfUwC8vYZEBc
         y61BBydpKsfTmpgL437BzxhVsfptcrpfq0FBRFzKJAOcaB8ir3JcnpIDzj0xah6LoD4D
         p7bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=oKXYvkzbAHnLf4Q/hIMN6pMELkeRbB1zoPMlVpolYQU=;
        b=JRmy0ya+XcaQjiK8yDvU0RmMR+R5nCpQBkLWvNpIcCrUIF2bL6TFV4jtHIDBFl2T8H
         q950zJ1Nn7wOa+reO8QpSJ+5O6xBlAwJdmfL+haZZ8K6fZ33bhiaYcsOxETZEwFFaael
         yX5iFxgL9zRtXHWqVE4SzmRm9eLJ82nuFrp6SWeoOXrlcF3UrOh/eWoTBm+BmWwEgvzR
         pmEdJcFcuO8rGOl4vne36GhOea2RyGOIplvZMjdVbkyr2URJxiF+abl/SZO8ZY+U941N
         HdnylqwmkuOoPpaT/fuTJj+mPSCI0NV0BKeVL3Q1zhkGnbJETV/ftlNuRQuiqF7aTk/A
         pPKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=a1WHWnai;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10sor11177959qkj.57.2019.03.27.04.34.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 04:34:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=a1WHWnai;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=oKXYvkzbAHnLf4Q/hIMN6pMELkeRbB1zoPMlVpolYQU=;
        b=a1WHWnaiQv6dJHCs2ShSvtL8aE2Fv1WGb/onjA9ltzQwFMdf9pOBvhAQXCJfJaIn9J
         euLec8ZUn8hCr4eNEAgYW5GRMfRd0U5lMZhI/8hS5r4GRQ6XcCXsOWFIeUyKwE8WQhLs
         vaKtgpG1BX4PlrPQOJJrIRT6M+rVSgdFFvoa3s7vdeHcVR9IdrA0YmcPIN7BgMJznet7
         oNe0eMGUE4uOVF5+AuxJviWIFAciAEdJsB/9zBYYwb4iydZdR3iRqBhO10SnFHMTbTbT
         r0ZZIYy293WrW0YIYztolQy2xdjDo+Glv8ky9986s/DxMV+SvqDc3iT5io87BuPqTo7a
         xCiQ==
X-Google-Smtp-Source: APXvYqz6Zcg1acfAJBgk15Q+CQzMSU639OLUibAyEcKgeoMxLcQv5XpzL0DGrNAsf5FjTGfoyJhK5A==
X-Received: by 2002:a37:5c05:: with SMTP id q5mr26594594qkb.20.1553686473610;
        Wed, 27 Mar 2019 04:34:33 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id v4sm11903344qtq.94.2019.03.27.04.34.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 04:34:33 -0700 (PDT)
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, cl@linux.com,
 willy@infradead.org, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <651bd879-c8c0-b162-fee7-1e523904b14e@lca.pw>
Date: Wed, 27 Mar 2019 07:34:32 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190327084432.GA11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 4:44 AM, Michal Hocko wrote:
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index a2d894d3de07..7f4545ab1f84 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -580,7 +580,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>>  	struct rb_node **link, *rb_parent;
>>  	unsigned long untagged_ptr;
>>  
>> -	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
>> +	/*
>> +	 * The tracked memory was allocated successful, if the kmemleak object
>> +	 * failed to allocate for some reasons, it ends up with the whole
>> +	 * kmemleak disabled, so try it harder.
>> +	 */
>> +	gfp = (in_atomic() || irqs_disabled()) ?
>> +	       gfp_kmemleak_mask(gfp) | GFP_ATOMIC :
>> +	       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> 
> 
> The comment for in_atomic says:
>  * Are we running in atomic context?  WARNING: this macro cannot
>  * always detect atomic context; in particular, it cannot know about
>  * held spinlocks in non-preemptible kernels.  Thus it should not be
>  * used in the general case to determine whether sleeping is possible.
>  * Do not use in_atomic() in driver code.

That is why it needs both in_atomic() and irqs_disabled(), so irqs_disabled()
can detect kernel functions held spinlocks even in non-preemptible kernels.

According to [1],

"This [2] is useful if you know that the data in question is only ever
manipulated from a "process context", ie no interrupts involved."

Since kmemleak only deal with kernel context, if a spinlock was held, it always
has local interrupt disabled.

ftrace is in the same boat where this commit was merged a while back that has
the same check.

ef99b88b16be
tracing: Handle ftrace_dump() atomic context in graph_trace_open()

[1] https://www.kernel.org/doc/Documentation/locking/spinlocks.txt
[2]
	spin_lock(&lock);
	...
	spin_unlock(&lock);

