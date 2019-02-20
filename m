Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02AB1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0CC12086A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0CC12086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47CDC8E0007; Wed, 20 Feb 2019 05:30:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42C778E0002; Wed, 20 Feb 2019 05:30:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D918E0007; Wed, 20 Feb 2019 05:30:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9EB88E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:30:44 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d31so5682983eda.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 02:30:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=fWz300JeWbIddGn5N0Y0I5/2ARMEgbJawIbWUzPQIow=;
        b=OWKN6mdfWNw9DWX2kdxgA6jojclc2vD6NIspvvpFIPeOTy/CohT3DODpWo8ajnisMi
         EsrQHfFsSnxUD2N8dUGtAvvPjdGgxbe9rKTIdRQT8/EaTEMegzKFehh7I2qzat0T9QZ/
         MuE8GIH6UBwhXSnmYm8fWJho6Zoj5Z9a9WUqyqPJ8GRP565SSwdJYK7H+Vg6sXzi1XuU
         e9d4xQJSHLcKkAGqpEawRmbhbm4OpUE7ppUIu01b1rgSs6Stbso4SI9wydyWlizR89EU
         rCsKdyYgh9R8sdIR6wA3FM2Vc7Xv0qHvwVRUhVrMZHBvErKpUnzQBf1Nq4B3cS+zMnqJ
         qkhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuZ0y0l9RGfvJjeLWVBQDjGn/OhrkhG+tfn1sQZb1XZ2MMqk6pys
	Ts5Tthwz71th4MiRPbAw6qqDWqtY46mLvughCJ3MbkOoiCR5pN2BoHayUS7rKIuZxnLrCG22ebM
	V3EGxZu039iLYTFbAtsfmgc+QcPA9Z1PXV7g563OpM/KmIegXn9sjFJX286y9If4G7w==
X-Received: by 2002:a50:adfa:: with SMTP id b55mr27510208edd.160.1550658644375;
        Wed, 20 Feb 2019 02:30:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbR20GkKpd6ZR9Fk85OQ1SOr7OugidjP3fJBU/Rer0gD6LuSLSTbQRop7xxfoV/OgvEAopF
X-Received: by 2002:a50:adfa:: with SMTP id b55mr27510142edd.160.1550658643519;
        Wed, 20 Feb 2019 02:30:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550658643; cv=none;
        d=google.com; s=arc-20160816;
        b=FXPJBs7eVAY1hGLDkAsIEoNGF52Q6yU2uem483p1OILtdsfEzMsy3oHtWCmCLETC3d
         1J4r/RCx4Rv1udZmNRFAI6HcCX48ECntGBx14Bmaquoxtau3SyW62gn8zdl2yQ+MYIWq
         rzqKJgi0Qb/ac7R56Iv89q+JnmoruoCfm5nIT13q03i/dKlWQk97k0A67oE+UkPv7cw1
         6soi3tkQ4YfiPnzoed5GQj3PNTvz4q4mldYm9+yyhjPvGYuOGHDB8j73SBgpzYq0b3C8
         gcBXyKva5se2H3kYcxcK9jUpM9Bl+Pgekw86BKy9H8yIcN4cVXwb+r6XYrrZaPELxyQb
         U+0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=fWz300JeWbIddGn5N0Y0I5/2ARMEgbJawIbWUzPQIow=;
        b=SJ36D0LCV+gxlE/lg680d9bBJAtN/pCdvIUW0X7zAqC6px4mC3pQSKxKJOfvn3kkGD
         yJwRDjOVdfkF2uhMcshSqLW/xqqu+FSO6TwrTnyFhDb4NwjPaS7ZnK6nJ7hXIRyV8nlg
         AmIhFsqrRq6zcpz9McAfUweaGitz65PJ8XQKdCNi2xLdeDc5QvdBnvGuYz/y7d18Ldw2
         tT944qgZ8+5L7xI/dAjngxzJQv4tL5ml4CF2MsbQg4pWeVmzNRf1LCK6sAL3v5stkSBh
         vS4cA1+RWugzAhud1CXa1P2zJUBYwkR+TJ6FjefCtphJzrBz+30TZ7gMG6OMEO/JO5I5
         9lIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23si4603108ejq.139.2019.02.20.02.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 02:30:43 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 70967AF69;
	Wed, 20 Feb 2019 10:30:42 +0000 (UTC)
Subject: Re: mremap vs sysctl_max_map_count
To: Oscar Salvador <osalvador@suse.de>,
 "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org, hughd@google.com, viro@zeniv.linux.org.uk,
 torvalds@linux-foundation.org
References: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
 <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
 <20190218111535.dxkm7w7c2edgl2lh@kshutemo-mobl1>
 <20190219155320.tkfkwvqk53tfdojt@d104.suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <5358bb76-be75-953d-8268-a2b889a44c72@suse.cz>
Date: Wed, 20 Feb 2019 11:30:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190219155320.tkfkwvqk53tfdojt@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/19/19 4:53 PM, Oscar Salvador wrote:
> On Mon, Feb 18, 2019 at 02:15:35PM +0300, Kirill A. Shutemov wrote:
>> On Mon, Feb 18, 2019 at 10:57:18AM +0100, Vlastimil Babka wrote:
>>> IMHO it makes sense to do all such resource limit checks upfront. It
>>> should all be protected by mmap_sem and thus stable, right? Even if it
>>> was racy, I'd think it's better to breach the limit a bit due to a race
>>> than bail out in the middle of operation. Being also resilient against
>>> "real" ENOMEM's due to e.g. failure to alocate a vma would be much
>>> harder perhaps (but maybe it's already mostly covered by the
>>> too-small-to-fail in page allocator), but I'd try with the artificial
>>> limits at least.
>>
>> There's slight chance of false-postive -ENOMEM with upfront approach:
>> unmapping can reduce number of VMAs so in some cases upfront check would
>> fail something that could succeed otherwise.
>>
>> We could check also what number of VMA unmap would free (if any). But it
>> complicates the picture and I don't think worth it in the end.
> 
> I came up with an approach which tries to check how many vma's are we going
> to split and the number of vma's that we are going to free.
> I did several tests and it worked for me, but I am not sure if I overlooked
> something due to false assumptions.
> I am also not sure either if the extra code is worth, but from my POV
> it could avoid such cases where we unmap regions but move_vma()
> is not going to succeed at all.
> 
> 
> It is not yet complete (sanity checks are missing), but I wanted to show it
> to see whether it is something that is worth spending time with:

Since move_vma() seems to consider only the worst case with the
hardcoded slack value of 3, I think we can afford to do that here as
well. And IIRC also nothing considers the possibility that the moved
area might merge with neighbours at the new address?

What worries me more is the amount of checks in vma_to_resize() that can
make things fail after the munmap was already done. Could it be also
called upfront? (And shouldn't it only be called when newsize > oldsize?)

Vlastimil

