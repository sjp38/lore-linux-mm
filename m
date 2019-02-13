Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB0A9C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:22:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7790F20835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:22:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7790F20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12DBE8E0002; Wed, 13 Feb 2019 14:22:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DC0E8E0001; Wed, 13 Feb 2019 14:22:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE6BF8E0002; Wed, 13 Feb 2019 14:22:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97A708E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:22:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so1444748edh.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:22:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Q6vEWTW35opmCQKNqyHy4VQAtcYCXhbRYGzBwGpyjhY=;
        b=oja8/BEVlSIhs+GniZbK4jpRJhdu2KUhkoHtVEKB9JF2/HrzpG4CKP+beBlyRrcidZ
         eERpZrujj6CiB14aI5fFg16iRp4T7RqyMPSHwEm4YKb4i2ccdHfVUZ07q2yYGrN4Jo2U
         bPgj9mWu3TIXBixdlpjJP+/4hxY9Yd3mrvDG9vcnCzyJ6FcnDyiEd6Szs1mUiqu0qELU
         ec+5iVphucAiBqVPsPW37kt4YTLPR8V+bib3EsvWTBzMy9AmDg2XcFSouM2qpZy30mAQ
         s/M1aTk2yKZ5EEpWg28712QADQ73YSeyn2rMUp5IHeRxCBk36SNnlIhgch0gm1mE5prG
         aAig==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: AHQUAuYBWfRNii1artr3GWJMyDSnKC+rB58nPBMEgibAXPU66+3qIRZX
	9isSt5xubwoipCxQBWFmV0EbGrg9jS+mgIDB+cobnof4XCFX1FlRqjW9dLQSdr2A6brsmSa6ZTC
	LML/IAD6BCupWvqltXtebCFklRIEB1hoJuPjOfIOsc07DBDIPZDlmOFar3dyXAAM=
X-Received: by 2002:a05:6402:185a:: with SMTP id v26mr1633386edy.163.1550085757172;
        Wed, 13 Feb 2019 11:22:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbi2BOc5Nl+PVoaV9eE7bftm0ohGjh5fRs/9v65VpyS90JtwJ+xV3eNT8957FdJHLkiki1
X-Received: by 2002:a05:6402:185a:: with SMTP id v26mr1633322edy.163.1550085755951;
        Wed, 13 Feb 2019 11:22:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085755; cv=none;
        d=google.com; s=arc-20160816;
        b=AYMqdiCvy1fvInocMwmIL+i7kXbj7r+0EL5imEcyGh3dcRq1zsf7qRkjlUtHpcr3l7
         UE1Ci161fc8AoNkbQCsZcFOfEe0x0JQYF8Ajx4ESHAJt3+6nGSGyJsIlVUiGYNXgxjPU
         R16qJLVPIVqr0yasvHB0J+mC8f5HB81zU/rRHPM/i7UpNhaP1M5LruZ3RI5R/TtdX0lG
         AsOVbwGLo8y5LWgtUv9SZDQQCQ8zkMNEJrHydyMg1GpcRXF00Jkato7HrUjLjwZRUfAg
         NEiCCr5z1Iia1bDxlntkHJW8ODH3Mu3YwnSaIn7BK6NpPAkeQM5BavTudwzv2m4N8AW+
         qAtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Q6vEWTW35opmCQKNqyHy4VQAtcYCXhbRYGzBwGpyjhY=;
        b=QHnBZSDAMeEvMClhs6lrmpbzb/ODFETUwkEuvDtJTHsNkU3OL8EfWG7wdO+fndqKL0
         XkYCibUGkjlLztBkT9VE/VAJUzyZFBaGxhTPTuaZLht7EuBFWupwu1iaCtOYkjT6A0UX
         IgqozIDlWeTIoagZCjwMKKyanm1xgH2TSuljR95swdtCoQI1FLl0n3ftZoGsr7pmgoAo
         2D+GzJ+ZmutLKA5AonF+z7Nm1hvvjeswoXtKrgl4FMBu97Zpa6pm5sCyLC1pbW9hIbMW
         biBd9nIvw0fcoZVRqusWJNkZgfGDU408vErXL+1Mt6xTJoCEPXThoe2zpyyprmnnqQJ1
         bwzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id p18si39431ejx.292.2019.02.13.11.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 11:22:35 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 0F08B100005;
	Wed, 13 Feb 2019 19:22:21 +0000 (UTC)
Subject: Re: [PATCH] hugetlb: allow to free gigantic pages regardless of the
 configuration
To: Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-riscv@lists.infradead.org, hch@infradead.org
References: <20190117183953.5990-1-aghiti@upmem.com>
 <16a6209c-868b-8fd5-a70a-6e0e1ecb62d4@suse.cz>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <7801de9c-9a8c-fb56-442a-6e530e52e0d8@ghiti.fr>
Date: Wed, 13 Feb 2019 14:22:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <16a6209c-868b-8fd5-a70a-6e0e1ecb62d4@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/13/19 6:27 AM, Vlastimil Babka wrote:
> On 1/17/19 7:39 PM, Alexandre Ghiti wrote:
>> From: Alexandre Ghiti <alex@ghiti.fr>
>>
>> On systems without CMA or (MEMORY_ISOLATION && COMPACTION) activated but
>> that support gigantic pages, boottime reserved gigantic pages can not be
>> freed at all. This patchs simply enables the possibility to hand back
>> those pages to memory allocator.
>>
>> This commit then renames gigantic_page_supported and
>> ARCH_HAS_GIGANTIC_PAGE to make them more accurate. Indeed, those values
>> being false does not mean that the system cannot use gigantic pages: it
>> just means that runtime allocation of gigantic pages is not supported,
>> one can still allocate boottime gigantic pages if the architecture supports
>> it.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> I'm fine with the change, but wonder if this can be structured better in a way
> which would remove the duplicated "if (MEMORY_ISOLATION && COMPACTION) || CMA"
> from all arches, as well as the duplicated
> gigantic_page_runtime_allocation_supported()


Yeah, totally, we can factorize more than what I did. I prepared a v2 of 
this
patch that does exactly that: remove the triplet from arch specific code
and the duplicated gigantic_page_runtime_allocation_supported.


> something like:
>
> - "select ARCH_HAS_GIGANTIC_PAGE" has no conditions, it just says the arch can
> support them either at boottime or runtime (but runtime is usable only if other
> conditions are met)


And the v2 gets rid of ARCH_HAS_GIGANTIC_PAGE totally since it
is not needed by arch to advertise the fact they support gigantic page,
actually, when selected, it really just means that an arch has the means
to allocate runtime gigantic page: it is equivalent to
(MEMORY_ISOLATION && COMPACTION) || CMA.


> - gigantic_page_runtime_allocation_supported() is a function that returns true
> if ARCH_HAS_GIGANTIC_PAGE && ((MEMORY_ISOLATION && COMPACTION) || CMA) and
> there's a single instance, not per-arch.
> - code for freeing gigantic pages can probably still be conditional on
> ARCH_HAS_GIGANTIC_PAGE
>
> BTW I wanted also to do something about the "(MEMORY_ISOLATION && COMPACTION) ||
> CMA" ugliness itself, i.e. put the common parts behind some new kconfig
> (COMPACTION_CORE ?) and expose it better to users, but I can take a stab on that
> once the above part is settled.
> Vlastimil


I send the v2 right away, if you can take a look Vlastimil, that would 
be great.
Note that Andrew already picked this patch in its tree, I'm not sure how to
proceed.


Thanks for your remarks !


Alex

