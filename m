Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 011D7C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 10:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDCB82084A
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 10:10:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDCB82084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ACB66B0006; Wed, 15 May 2019 06:10:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D826B0007; Wed, 15 May 2019 06:10:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44D2A6B0008; Wed, 15 May 2019 06:10:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E76AD6B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 06:10:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so3139877edz.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 03:10:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xPHvV6MplxAj87ntXnCFc+YS5ZR+uPiy/SsXzFQRa+I=;
        b=iPNhsZKUkXhgJ42mPehVZwZbN8kvw0oAGD2WCS0P/Hw0Cn3SAH4dxHQ/9yh0jKuxwJ
         B5kHsTK/B0ctR1FJ8uc6BSDAnhdDlQKdu50ULf/UBzPqpxORSNKgeHZHUTodFkJiwD5T
         i6R80HILKKdOZv/mh9ACXHrvlQYd8a0kabGu5TPaZyG8cJ9oCDmV0poK+cehcqazewQ9
         jUDdU28Rd4Wub4ruWNHHN67EooRKwCLcdNlv3rJAnV3danDsRhJtoaIoio1hQFlUf7kR
         dloHaXzcFgsnG0+C/YiU2TxtiXR/nD6oiVzs5qhu1EAIA9XYPaYbdtw1dp2Tzmoid5qo
         Gjpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUcZTT2ofYkTi91QltMd9X2oVR0SX0zXOC+kgcwLB0PvTBPtao/
	MvwgfwXkZ/pr6tr2pxXy20NEqwxnbrsNWy5e3dEdHDF86NU1pEgNZs3qei/TIuoWy45Yr6WnTBQ
	2onmTdOmz21ckk/CFd6xaamHHYs7cvBxzIIIxMd779hr13PtIZD4iBshLfkf1N+fU5g==
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr31817127ejb.218.1557915040502;
        Wed, 15 May 2019 03:10:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIT5V6tKNjbDAZ6bK7pMhGyXzme7DDzyvH8g2s4nssC2DshN6D7BWpdBmgj+1mSrVvQd0k
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr31817078ejb.218.1557915039833;
        Wed, 15 May 2019 03:10:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557915039; cv=none;
        d=google.com; s=arc-20160816;
        b=LWW430iHGjaXrlcFzr6jkebhBBydSQATvk9/Ph4L3HDFnVNWh9nlsunOcZ7PC04O9W
         +gE0tyYj3KJEIBJPaJ0SoMI/DRetIdqFFmX8+ZJltD/BRtu8B2uaackJu0e5qkFcK50G
         vo8W28E8ywg7t4ruPIOS5AbXwfctK+/4Js+RhIIi4ddVsvLX1aLHBsThAbxfiGNjGjY/
         6CW6uQhOAN2C/6ywQtTZfetuz/MBklUqmhI6dfBzHYdhnOXffddZ3YdslSVoJv3P3hrT
         DZ/mxmfF4z2xXdqjQhCg+GOSGVLeOJOml3M1sZxa/yIOEIqcgno8j4BAmH4LPnHcHOOV
         TOwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xPHvV6MplxAj87ntXnCFc+YS5ZR+uPiy/SsXzFQRa+I=;
        b=WX6MGsCHzplQh8kb9QRfwgbOrnvh9PtS1Vzq9/Y8yN7yriPeIZQjEJ4cElJnXuq0+L
         zO5YSIrFLiDhm68/IafLHflzfUhTuvACfj3ixAG831zZWENSQS8ehcZXWzH+dF7oVCHL
         BrSrb57J1CCm6aS2Mb53+mXBdv+WRuZp1T/JoxCX1B6oZziCkiyDOr/c/7TLXgze9QJI
         FsLickskPog5jXlX0PfBDDtNDrXV9VqgfVN+nJaKooQmHh+mKQHY6ElxZ7XoPodqPKO4
         z3fxN8fdmOhlKbINtMaGekMzjMlQ/HeB5y+n1m5JNcQHA1m0zQ+tXAQzg1njW3PrRpQq
         W+Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n14si1039113eju.288.2019.05.15.03.10.39
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 03:10:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A5D0280D;
	Wed, 15 May 2019 03:10:38 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 143C63F703;
	Wed, 15 May 2019 03:10:32 -0700 (PDT)
Subject: Re: [PATCH V4] mm/ioremap: Check virtual address alignment while
 creating huge mappings
To: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Thomas Gleixner
 <tglx@linutronix.de>, Catalin Marinas <catalin.marinas@arm.com>
References: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
 <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
 <20190515094655.GB24357@fuggles.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a0c3f9db-c6ae-556c-bc89-bd6b87b14029@arm.com>
Date: Wed, 15 May 2019 15:40:40 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190515094655.GB24357@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/15/2019 03:16 PM, Will Deacon wrote:
> On Wed, May 15, 2019 at 08:05:16AM +0530, Anshuman Khandual wrote:
>> Virtual address alignment is essential in ensuring correct clearing for all
>> intermediate level pgtable entries and freeing associated pgtable pages. An
>> unaligned address can end up randomly freeing pgtable page that potentially
>> still contains valid mappings. Hence also check it's alignment along with
>> existing phys_addr check.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> Cc: Toshi Kani <toshi.kani@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> ---
>> Changes in V4:
>>
>> - Added similar check for ioremap_try_huge_p4d() as per Toshi Kani
> 
> Sorry to be a pain, but in future please can you just resend the entire
> series as a v4 (after giving it a few days for any other comments to come
> in) if you make an update? It's a bit fiddly tracking which replies to which
> individual patches need to be picked up, although I'm sure this varies
> between maintainers.

I wondered for some time about both the ways before landing on this side as it was
pretty minor change. I understand the concern and will follow the suggestion next
time around. If this one requires further update, will make it V5 and carry the
change logs from here.

> 
> No need to do anything this time, but just a small ask for future patches.

Sure will do.

