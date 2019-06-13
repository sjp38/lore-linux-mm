Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 535B2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:27:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1615B2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1615B2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAB396B0270; Thu, 13 Jun 2019 07:27:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A828F6B0271; Thu, 13 Jun 2019 07:27:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9992D6B0272; Thu, 13 Jun 2019 07:27:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73B5A6B0270
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:27:53 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c64so6655024oia.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:27:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=/qpDQQVjcxZb5/ubb8japavI83P+cCtsP2OLrvnrPsk=;
        b=WJWhVcUDH83MfRFJSRw+x/E34MgGqkbZeSOasf5bCvnFZwjYFdKCGPIqaKeWKR8bFI
         YBiKTWVfkhaVuNJi4NZukRKXxukK2ufDAp5UqvJycglLqaku4ghgGE3rEZBrlaObJUYs
         N6cIK/ET7Ap/nTFiRRrfBXIRbihhQ3fX2GBGrvhGk8qJbQgA54wpBVXEyptMyeEh4Q1v
         DuHW/KPSH4bf8GV0rb/chYjZYytlgasSIzBFtuQxJ281mB0ZNVFIBULUJa6DXFb5VPM6
         K5Nt2qxroM1HHKPDnn5mAv+6Y5QQzfVVlcY4ufjCiblGZKQ+fF/NKSjwt0nhrBShshag
         TsGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAU3WZ0+t3Tl2hPHplKc2jpnuFS32pR693fps9z2LTH+AcrwhJQ7
	jWr5KJSLMScazh8EsS/R8SRqv/PvaNu0WHuO34D1oatSshw24BgY2JdxTGOIX1lpAwbqT7LBgDy
	z5X6K8FS6twlF9IeoE440t5D6NSd/lN3Xq3FTgSQqaistkuUANQ28Cmbadzcr2k0SUg==
X-Received: by 2002:a9d:5510:: with SMTP id l16mr28779732oth.63.1560425273179;
        Thu, 13 Jun 2019 04:27:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXH6c+y8D/NNHLiiVXeWjQJFifbh7Vr04z0qQyGlcoSQO/h4JEePY+m4sYMtAB/imExQHr
X-Received: by 2002:a9d:5510:: with SMTP id l16mr28779682oth.63.1560425272428;
        Thu, 13 Jun 2019 04:27:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560425272; cv=none;
        d=google.com; s=arc-20160816;
        b=UMAydbulz+UW6lda8k5bZOLNGPS09s2r4nrfDaNsXL65xSNANlPA/uDUhv2OTwm+Xh
         y+JDnTGRa5IOANBYpN7gku9POEWgo3BIZy82ScPyD/VI8QlFcN/V9Hg+nXjOPF5WEJ1N
         y1IX1xv+8OYxYvnv9Xt1O8WUKOak4UItW9XVZ9vIrcFyCrK+CqR1+j/iXozbP86NqW6K
         +jWIxuNFQ+oNY5jENUG7sscRsZYsVvCzTWrYEFtKn00fU16nePVS2zIsv72SBA8Llfa4
         4I/eigJS2B3HAMjeG9rFH3T/9D+i52o4gnXNuBdPI0gOkGGwLEJ/u4OHzVmOE8vAcVs0
         +WWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=/qpDQQVjcxZb5/ubb8japavI83P+cCtsP2OLrvnrPsk=;
        b=M0i4EGdUbfmWJWyGexyXTkhVZdUjLhNF0g8D6GYASp4xIa2gynNXGwMYdOVFdTdU2V
         /yFCa5Wu7M+R6mOqW8NrdLzopoT7bBuAwwq1YUlrjk/sBMUhb6/ae/K1GJAp9u2CV6SS
         9AkbpA3GU1T6N0AATOjH0B89MLSTiMVahZegoq2t00NlBUSPfbMnWh2njsHL/SVKx7aN
         m8KheZcafP6+QrB9PSf8Ty9+jqTtP/W7dE9wbaoxG0elaINQCcczFZu7qbP5WGKGRFvY
         pB+KcJn+EjXDaZSSsMI8Cv3kx8s6iQy/flkhlG63+rcpc7TTR+ubYZLEkEQXrpHgjh5M
         DKqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id m15si1571507otq.260.2019.06.13.04.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 04:27:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 6D86DE8FDE300608686F;
	Thu, 13 Jun 2019 19:27:48 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.439.0; Thu, 13 Jun 2019
 19:27:43 +0800
Subject: Re: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump
To: James Morse <james.morse@arm.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <51995efd-8469-7c15-0d5e-935b63fe2d9f@arm.com>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>, <horms@verge.net.au>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <638a5d22-8d51-8d63-2d8a-a38bbb8fb1d6@huawei.com>
Date: Thu, 13 Jun 2019 19:27:40 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <51995efd-8469-7c15-0d5e-935b63fe2d9f@arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/6/6 0:32, James Morse wrote:
> Hi!
> 
> On 07/05/2019 04:50, Chen Zhou wrote:
>> We use crashkernel=X to reserve crashkernel below 4G, which will fail
>> when there is no enough memory. Currently, crashkernel=Y@X can be used
>> to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
>> are requierd, capture kernel will boot failure because of no low memory.
> 
>> When crashkernel is reserved above 4G in memory, kernel should reserve
>> some amount of low memory for swiotlb and some DMA buffers. So there may
>> be two crash kernel regions, one is below 4G, the other is above 4G.
> 
> This is a good argument for supporting the 'crashkernel=...,low' version.
> What is the 'crashkernel=...,high' version for?
> 
> Wouldn't it be simpler to relax the ARCH_LOW_ADDRESS_LIMIT if we see 'crashkernel=...,low'
> in the kernel cmdline?
> 
> I don't see what the 'crashkernel=...,high' variant is giving us, it just complicates the
> flow of reserve_crashkernel().
> 
> If we called reserve_crashkernel_low() at the beginning of reserve_crashkernel() we could
> use crashk_low_res.end to change some limit variable from ARCH_LOW_ADDRESS_LIMIT to
> memblock_end_of_DRAM().
> I think this is a simpler change that gives you what you want.

According to your suggestions, we should do like this:
1. call reserve_crashkernel_low() at the beginning of reserve_crashkernel()
2. mark the low region as 'nomap'
3. use crashk_low_res.end to change some limit variable from ARCH_LOW_ADDRESS_LIMIT to
memblock_end_of_DRAM()
4. rename crashk_low_res as "Crash kernel (low)" for arm64
5. add an 'linux,low-memory-range' node in DT

Do i understand correctly?

> 
> 
>> Then
>> Crash dump kernel reads more than one crash kernel regions via a dtb
>> property under node /chosen,
>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.
> 
> Won't this break if your kdump kernel doesn't know what the extra parameters are?
> Or if it expects two ranges, but only gets one? These DT properties should be treated as
> ABI between kernel versions, we can't really change it like this.
> 
> I think the 'low' region is an optional-extra, that is never mapped by the first kernel. I
> think the simplest thing to do is to add an 'linux,low-memory-range' that we
> memblock_add() after memblock_cap_memory_range() has been called.
> If its missing, or the new kernel doesn't know what its for, everything keeps working.
> 
> 
>> Besides, we need to modify kexec-tools:
>>   arm64: support more than one crash kernel regions(see [1])
> 
>> I post this patch series about one month ago. The previous changes and
>> discussions can be retrived from:
> 
> Ah, this wasn't obvious as you've stopped numbering the series. Please label the next one
> 'v6' so that we can describe this as 'v5'. (duplicate numbering would be even more confusing!)
> 
ok.

> 
> Thanks,
> 
> James
> 
> .
> 

Thanks,
Chen Zhou

