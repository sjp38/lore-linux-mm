Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39F64C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:52:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9F9620882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:52:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9F9620882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 250346B000C; Thu,  4 Apr 2019 17:52:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201676B000D; Thu,  4 Apr 2019 17:52:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C9226B000E; Thu,  4 Apr 2019 17:52:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B18F86B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 17:52:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e55so2181894edd.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 14:52:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=A6iA9Z+bco4tHmzu2VXiXCyZpRsXn9EoTLRl0zthUAY=;
        b=LNb5fkz+SNilhCTtQwQq8bd8vCaOwPXa8RmyhazGI9cYtJJHJJhikVwNX3V/GwdzXw
         uhYJCacXRCskpR6oydqJM8A7lJ6Vw12S2346D5nOg6o8YQPL0MMOpNvVKyjmFYkOIITI
         KFAv5Ic09nFoC703eyAn9MF5yfSsNJLEGRzbQpXhtDuHr5ud8fcOgp2ZuTL5kPX84gXM
         tR3/1Yt4diJjefDlMjLHVPNJbnbmAA/5t5VYMhVEXQECTj5+7r2LI29cwkbzGpkIaZzb
         MEMkoVFQSa0AFtVove1vnywGXXa9yW7UYiwJE5R0+vBFwUF4ggGRfr54FAZkvmYL9Opr
         wQbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXc2vDAV8/oVlHgT8J8SjLFfQx1vQqc77IrtNq13XrlHa8Vk1Jl
	U56XeuX/RxW9j9P9O9k5/NEL7b/e+6wU0+mpsvTAZ6xGs97Su0T7EwznePhnSw1olma5vVP5M88
	/o93CpUuHP+PqRFSZfHMNK23lSUlEiah1sWJ0B1mm1oFtgy2+WRljKH7N5AEWj5EhXw==
X-Received: by 2002:a50:95f8:: with SMTP id x53mr5445003eda.267.1554414745290;
        Thu, 04 Apr 2019 14:52:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz7yDeOd6HVCvgkn9/7AGWc3A8RK0zdgfU/IEOQ5YPkSPuFanSCRhfzebfDGjF82KGxhq3
X-Received: by 2002:a50:95f8:: with SMTP id x53mr5444976eda.267.1554414744371;
        Thu, 04 Apr 2019 14:52:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554414744; cv=none;
        d=google.com; s=arc-20160816;
        b=wAtH+XX033EX0OSgfrMZwPdcadvUlancIjoumzlXee+UlAG+0B324CwctpHNGhStqL
         95WnSntVVlHJUUJe9fiLC1vbfXuSNaiMwSmTb3jYoHE++5/L4mKxhhJAmzplw+7NaHI6
         XzxMRkzydL3fJGw2MWil/yb4bw5YxGACRr/K9uZpuH9kDDCdQHU4/CSIEa3O6Vx6OI3A
         DMaWQb8Z7K0W02Ycaq3JD7741YupXCWt9a31vzw4a3QNv7nyP22RhXBHMIpLwHnR/nPJ
         GTLgjslAAS3uYC1RGYWGGKHmbGVvY472gfyoeVax/g6lQdRkYRILS4c8S0cq5uVxwJ1I
         dcyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=A6iA9Z+bco4tHmzu2VXiXCyZpRsXn9EoTLRl0zthUAY=;
        b=s1FgWEJRC81uz623SnVSIG7uiDqAOixCr1nH4iMWq0CzOmj3fnYK+beqVqAsE9H73a
         URi8DmXOJpjFTLQ4cKYs5+GMmhsxc9K40+ezKh/Wi5WfH+FsVnQOLris5cb7mVPs6elz
         A37CFXDM7IKG5u2eG5tkkxA6IU5f/pgEW7brNA+tAlGnuTl209i2toyATxT6Ddgriu84
         UNaIPfaY6S4C+Wb1ceL9e04En2+OHmj4y8r1EsKPxNw2T5FDe3VsdX1fYxV61YjQIfQZ
         s1/y+yPNVgF16/ai2cPyLoOA4Eu/YBexJB32YVtu+Sv4moUeL7fCQWbF379kzjjirVJy
         Rkzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a47si1151955eda.24.2019.04.04.14.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 14:52:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2CF03AEE6;
	Thu,  4 Apr 2019 21:52:23 +0000 (UTC)
Subject: Re: [RFC 0/2] add static key for slub_debug
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org
References: <20190404091531.9815-1-vbabka@suse.cz>
 <01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <74806ef2-2ffa-c229-09e5-29aa9e852ca1@suse.cz>
Date: Thu, 4 Apr 2019 23:52:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/4/19 5:57 PM, Christopher Lameter wrote:
> On Thu, 4 Apr 2019, Vlastimil Babka wrote:
> 
>> I looked a bit at SLUB debugging capabilities and first thing I noticed is
>> there's no static key guarding the runtime enablement as is common for similar
>> debugging functionalities, so here's a RFC to add it. Can be further improved
>> if there's interest.
> 
> Well the runtime enablement is per slab cache and static keys are global.

Sure, but the most common scenario worth optimizing for is that no slab
cache has debugging enabled, and thus the global static key is disabled.

Once it becomes enabled, the flags are checked for each cache, no change
there.

> Adding static key adds code to the critical paths.

It's effectively a NOP as long as it's disabled. When enabled, the NOP
is livepatched into a jump (unconditional!) to the flags check.

> Since the flags for a
> kmem_cache have to be inspected anyways there may not be that much of a
> benefit.

The point is that as long as it's disabled (the common case), no flag
check (most likely involving a conditional jump) is being executed at
all (unlike now). NOP is obviously cheaper than a flag check. For the
(uncommon) case with debugging enabled, it adds unconditional jump which
is also rather cheap. So the tradeoff looks good.

>> It's true that in the alloc fast path the debugging check overhead is AFAICS
>> amortized by the per-cpu cache, i.e. when the allocation is from there, no
>> debugging functionality is performed. IMHO that's kinda a weakness, especially
>> for SLAB_STORE_USER, so I might also look at doing something about it, and then
>> the static key might be more critical for overhead reduction.
> 
> Moving debugging out of the per cpu fastpath allows that fastpath to be
> much simpler and faster.
> 
> SLAB_STORE_USER is mostly used only for debugging in which case we are
> less concerned with performance.

Agreed, so it would be nice if we could do e.g. SLAB_STORE_USER for all
allocations in such case.

> If you want to use SLAB_STORE_USER in the fastpath then we have to do some
> major redesign there.

Sure. Just saying that benefit of static key in alloc path is currently
limited as the debugging itself is limited due to alloc fast path being
effective. But there's still immediate benefit in free path.

>> In the freeing fast path I quickly checked the stats and it seems that in
>> do_slab_free(), the "if (likely(page == c->page))" is not as likely as it
>> declares, as in the majority of cases, freeing doesn't happen on the object
>> that belongs to the page currently cached. So the advantage of a static key in
>> slow path __slab_free() should be more useful immediately.
> 
> Right. The freeing logic is actuall a weakness in terms of performance for
> SLUB due to the need to operate on a per page queue immediately.
> 

