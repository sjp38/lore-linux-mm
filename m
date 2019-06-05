Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFC84C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:32:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6391206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:32:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6391206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 429CD6B026D; Wed,  5 Jun 2019 12:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FF6B6B026E; Wed,  5 Jun 2019 12:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EF1F6B026F; Wed,  5 Jun 2019 12:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6FBC6B026D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:32:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f17so4626950eda.11
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:32:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fFcZ4SkDo55jbz9mzlNDhFKxa1lrOZkRCiSJNaSqEM8=;
        b=jNPbRGLI+ShB5JGWKy3dv6KRYAYQZoQcaaq5LnVAcsf90lHz66OgeTz7YxbT6Ay0Z5
         gpC4RCpN/lwh/u1NlRh/ec3b5Re8B/nZCMZXgp1Z8dpFgazKW+ni9DBG1yzhVBQZ2bVw
         1vqAuqmzsDnDl6tDRwQJRAbZ/8wdSobCDkg+cNDhoAPrwCADy1UhE730xvCtw8CV6E+y
         HwkKNPYDzpzGtLncuXmwselO3UsOMqSRiRBK8w+y0W2FvokDSZEPgtEluS2LYN1uR+7q
         qxRK1T/IoHWL+cjhhZQR5DSuv7Avzhxe+2KNhdIWmmnhTCV0OeS71BCfwQLu4OwzjlTh
         8EVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: APjAAAUxiGP709TOUCx0KMza7gzMEVS8EOWaZbQAZH5ELa/fX4/fnHP1
	ySid6IxFjwjAOnUFVdGH31tzlWz9JIRNT7abImtnJ47GdDCvmAkLfco9XZv2YqKne9xmEskwawa
	7hh5fd6hiwyHPFQfPUnlReTVw++NmcPI93Apiyfw3F9y02mGH1I+XE1H7HH8sa5teSA==
X-Received: by 2002:a17:907:2114:: with SMTP id qn20mr18886679ejb.138.1559752330419;
        Wed, 05 Jun 2019 09:32:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypwZRzZ4Q4mVYk7sxMUR1YIdW4A2rzHvqCCEB67/zWVMXOH7qahLfThE6k6W+ygeXuwYT0
X-Received: by 2002:a17:907:2114:: with SMTP id qn20mr18886607ejb.138.1559752329608;
        Wed, 05 Jun 2019 09:32:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752329; cv=none;
        d=google.com; s=arc-20160816;
        b=tdqWG1s6jw1da9h7dIPLu4c8Z/BhgMvLk/a8kZEzbFVZ1U1Dr94syUHBTJiGWfBVCg
         YOCPvppXBk66os3huMusma1uEjBik1xMxvl9odGyof/VMxap5dPVOVCQJEmoNKiNSDWQ
         9Cck60bFfqWAc2ZPZ2A5FH9t5n9aiDu2iGzOvL7y86RFJCgdxvHVSkdSkaVH1ZLUQioh
         hnKQLBw4fE89tjhSiU4KZuE7htFAgWx426KwCysNs3sxLkl/cQ4G9b2UNOaXJLZCDpIr
         EWuy0WGDs+lmtBlTKq2glQUGie1gjgkkC0Wz/+lNncQPBS+QF1CqrNFZLgLPeZhP0XjR
         YM7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fFcZ4SkDo55jbz9mzlNDhFKxa1lrOZkRCiSJNaSqEM8=;
        b=G1iraqE7A3OgoY4qYoYSiFKS26OKOtvCrctCyzMnPB07tJ349HYOjYmMYX627lLTUO
         pd4RIqccT37RZAxd7vhKljmmoFjZ65dzV3gzrBhgL0T9gYgcSaz6bC87ageldOoMWP6+
         umC7chWzJBwqZMYeXZUAyB2+t+p6dvEX5fojKTIHdD9YMDFhmvD1/8fxv32Aix0LagPQ
         5D3RzeTB1o0wwiLuHRCFgz2LKR44kjC9x/pMpXFnjBPF3ruLvLN/TUj1xV0PJWEe3k+L
         5jm6od449xu3iFcAyOu+NJHXVeFdv5EpA4NiDYay91qfKTWfUzNhcxgTQIl1p1MwB6rr
         llxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g9si1932375ejj.245.2019.06.05.09.32.09
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 09:32:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8EA8A374;
	Wed,  5 Jun 2019 09:32:08 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B9ED53F5AF;
	Wed,  5 Jun 2019 09:32:05 -0700 (PDT)
Subject: Re: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
 ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com, horms@verge.net.au,
 takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org,
 wangkefeng.wang@huawei.com
References: <20190507035058.63992-1-chenzhou10@huawei.com>
From: James Morse <james.morse@arm.com>
Message-ID: <51995efd-8469-7c15-0d5e-935b63fe2d9f@arm.com>
Date: Wed, 5 Jun 2019 17:32:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190507035058.63992-1-chenzhou10@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

On 07/05/2019 04:50, Chen Zhou wrote:
> We use crashkernel=X to reserve crashkernel below 4G, which will fail
> when there is no enough memory. Currently, crashkernel=Y@X can be used
> to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
> are requierd, capture kernel will boot failure because of no low memory.

> When crashkernel is reserved above 4G in memory, kernel should reserve
> some amount of low memory for swiotlb and some DMA buffers. So there may
> be two crash kernel regions, one is below 4G, the other is above 4G.

This is a good argument for supporting the 'crashkernel=...,low' version.
What is the 'crashkernel=...,high' version for?

Wouldn't it be simpler to relax the ARCH_LOW_ADDRESS_LIMIT if we see 'crashkernel=...,low'
in the kernel cmdline?

I don't see what the 'crashkernel=...,high' variant is giving us, it just complicates the
flow of reserve_crashkernel().

If we called reserve_crashkernel_low() at the beginning of reserve_crashkernel() we could
use crashk_low_res.end to change some limit variable from ARCH_LOW_ADDRESS_LIMIT to
memblock_end_of_DRAM().
I think this is a simpler change that gives you what you want.


> Then
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Won't this break if your kdump kernel doesn't know what the extra parameters are?
Or if it expects two ranges, but only gets one? These DT properties should be treated as
ABI between kernel versions, we can't really change it like this.

I think the 'low' region is an optional-extra, that is never mapped by the first kernel. I
think the simplest thing to do is to add an 'linux,low-memory-range' that we
memblock_add() after memblock_cap_memory_range() has been called.
If its missing, or the new kernel doesn't know what its for, everything keeps working.


> Besides, we need to modify kexec-tools:
>   arm64: support more than one crash kernel regions(see [1])

> I post this patch series about one month ago. The previous changes and
> discussions can be retrived from:

Ah, this wasn't obvious as you've stopped numbering the series. Please label the next one
'v6' so that we can describe this as 'v5'. (duplicate numbering would be even more confusing!)


Thanks,

James

