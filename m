Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02DA4C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:11:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A45672183E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A45672183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DD2E6B0269; Wed, 17 Apr 2019 04:11:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28A7C6B026A; Wed, 17 Apr 2019 04:11:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12B7D6B026B; Wed, 17 Apr 2019 04:11:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B03A86B0269
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:11:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so4012418edy.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+dbIHkoGyOqEVdp0DgCZVAFw5jfx9rrdWKKlpRofRRg=;
        b=uUinGngTaDt2ngdg2xTn+mtCEsGf/3W7YPNbv5PbUKi+uVkkgm/LfP3bi6YtoZje/6
         LkSf1MtQRaC1cl2h3k82h8MySiSV0P7qUGzXX5LDnaw2ExDjgUbJxnxtZ9ci5pzVGc1H
         UVicVK3aFS/StRzKyxvexFQKCfqltjIuabia28UhMhZ/qwwpdDaa8xrSFhpWRDaQgNC3
         OeB9YEJ1Eai8vk7zO9stFp8vtYz8chO5YqLp4V8gfXBOY8Xq5SkU9yK9Ab8Sa6ZpnRNO
         5sPAjCaX2YGCzq8mcnBAzd8LjI0UDIFqzLG/VDXPbpk2CKSFAl1+KObDe4rEmV+MoPWp
         8i+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVsAE/ix1BN6OP8YaO0ztqWWYDGxIo+B0LuupisjPtqdpR9oU2q
	2RtdBNg9ELCZHnvqDutUOzXnpSs6phQOwk7nvwjpKBFhwNb5RpiRRIKGy4XwGZgSIEAZfn1csNG
	RPzi9lVBv4YrCh1RFa25TDgvBBjeehAkzq+fAPV9tnQcBbVvgKrhLRFtoGk4FH0XxRA==
X-Received: by 2002:a17:906:2481:: with SMTP id e1mr25658088ejb.22.1555488673229;
        Wed, 17 Apr 2019 01:11:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7dZo1uTc9Z43+XfX+rcXyq9q2xq1PPwTUzD7v1k4dUQQmb3B5wpuZYIvd2Nsqf05xIpMZ
X-Received: by 2002:a17:906:2481:: with SMTP id e1mr25658015ejb.22.1555488671659;
        Wed, 17 Apr 2019 01:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555488671; cv=none;
        d=google.com; s=arc-20160816;
        b=tD0dolRGW+wcO+yHf2qDj3SbsSbWnHDhJuRI+qjRRBDusj/W3yJbZCLms2Vkw/71yZ
         UL5YZd22+Z7ZIfFyyu0OfXulh/r8ZNUEmf5IjoSk2vLANvU2AqI1ZyhW5W6kc4NN4YuS
         uDgjID3PKoNP6ZDlC/h6gWG4I70bBF8QvVMC0e0odr4N1r6j+uPtQ0YeYmcMvD3snsR8
         b6tQsoFHA75nl4vsPChUe1fAnAxbb6TVBJ/emoWmR9ng0IcrTQ9zoZX/Wc/3gyq+hYaC
         A7H8q0AdO7WsuLuHM3XVdxUs4x2Z06PXOFfmbGyjhuYmIdRcHRBSt7Evs1Bt8wGAg0pA
         pNqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+dbIHkoGyOqEVdp0DgCZVAFw5jfx9rrdWKKlpRofRRg=;
        b=iYdLQC/ZXcxDPAC27dnI2mAN6wEnEAyurnigMkogG8BoCpi1fzRWlrLqp83DJW1KWL
         ZfGdzJyB1+J3OvkT2O0F3hwEZIf0T8TFcL/IpvBS1tpKHrNxXY/J5QvdHvhd2ibZ+gZ3
         tfCde+S2gehluKK4YzfHLnxyUZc3MXlOPQjj2a5+fzkpedWv5gKwdf4pQhWKucVvQl58
         tmcV6D40Fmq+CZs8VCX+DQYoUPvmBop/KT+XAuSrcjFwWAt1OhB6SItFbhgrDHN+tPjZ
         j7CpYwrMh+FKj7gcRqjx/99Pyl8SpOlcfe/BddR4ZiFcLctiLCjQQ+q79FZjRFydwd/m
         z8Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a11si394072eje.123.2019.04.17.01.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:11:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A7A9BB12F;
	Wed, 17 Apr 2019 08:11:10 +0000 (UTC)
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
To: Christopher Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
 lsf-pc@lists.linux-foundation.org,
 Linux-FSDevel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>, linux-block@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>,
 Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Ming Lei <ming.lei@redhat.com>, linux-xfs@vger.kernel.org,
 Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>,
 "Darrick J . Wong" <darrick.wong@oracle.com>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
 <1555053293.3046.4.camel@HansenPartnership.com>
 <68385367-8744-50c3-8a81-be3a4637ea80@suse.cz>
 <0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <e1666bc2-13ef-21d5-1ed7-f1738d577278@suse.cz>
Date: Wed, 17 Apr 2019 10:07:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 5:38 PM, Christopher Lameter wrote:
> On Fri, 12 Apr 2019, Vlastimil Babka wrote:
> 
>> On 4/12/19 9:14 AM, James Bottomley wrote:
>>>> In the session I hope to resolve the question whether this is indeed
>>>> the right thing to do for all kmalloc() users, without an explicit
>>>> alignment requests, and if it's worth the potentially worse
>>>> performance/fragmentation it would impose on a hypothetical new slab
>>>> implementation for which it wouldn't be optimal to split power-of-two
>>>> sized pages into power-of-two-sized objects (or whether there are any
>>>> other downsides).
>>>
>>> I think so.  The question is how aligned?  explicit flushing arch's
>>> definitely need at least cache line alignment when using kmalloc for
>>> I/O and if allocations cross cache lines they have serious coherency
>>> problems.   The question of how much more aligned than this is
>>> interesting ... I've got to say that the power of two allocator implies
>>> same alignment as size and we seem to keep growing use cases that
>>> assume this.
> 
> Well that can be controlled on a  per arch level through KMALLOC_MIN_ALIGN
> already. There are architectues that align to cache line boundaries.
> However you sometimes have hardware with ridiculous large cache line
> length configurations like VSMP with 4k.

The arch and cache line limits would be respected as well, of course.

>> Right, by "natural alignment" I meant exactly that - align to size for
>> power-of-two sizes.
> 
> Well for which sizes? Double word till PAGE_SIZE?

Basically, yes. Above page size this is also true thanks to the buddy
allocator scheme.

> This gets us into weird
> and difficult to comprehend rules for how objects are aligned.

I don't think the rules are really difficult to comprehend for kmalloc()
users when they can rely on these alignment guarantees:

- alignment is at least what the arch mandates (to prevent unaligned
access, which is either illegal, or slower, right?)
- alignment at least to allocation size, for power of two sizes
- alignment at least to cache line size for performance or coherency reasons

The point is that kmalloc() users do not ever need to know the exact
alignment! Why should they care? It's enough that the guarantees are
fulfilled, and thanks to the "at least" part, the alignment might be
e.g. twice the size sometimes (e.g. 64 instead of 32), but that's
obviously not a problem for the kmalloc() user as the larger alignment
still satisfies the need for the smaller alignment.

(Implementation-wise a simple max(KMALLOC_MIN_ALIGN, size, cache_line)
is enough if all three are a power-of-two values, otherwise we need to
calculate LCM, but IIRC existing code already uses max() for
KMALLOC_MIN_ALIGN and cache_line at least in SLAB).

> Or do we
> start on the cache line size to provide cacheline alignment and do word
> alignment before?

I didn't intend to change how cache line alignment works, that's a
separate thing. Looks like on my system with SLAB and 64B cache line
size, I have kmalloc-32 aligned to 32, kmalloc-64 aligned to 64 and
kmalloc-96 aligned to 64, thus practically the same as kmalloc-128.
Adding the align-to-size-for-power-of-two guarantee would change nothing
here.

> Consistency is important I think

I think using the three "at least" rules above is consistent enough, or
I'm not sure what kind of consistency you mean here?

> and if you want something different then
> you need to say so in one way or another.
> 
> 
>>> I'm not so keen on growing a separate API unless there's
>>> a really useful mm efficiency in breaking the kmalloc alignment
>>> assumptions.
>>
>> I'd argue there's not.
> 
> 

