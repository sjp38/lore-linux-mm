Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4D47C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96CAA2073F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96CAA2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 236826B0006; Thu, 11 Apr 2019 08:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E5906B0008; Thu, 11 Apr 2019 08:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 124396B000D; Thu, 11 Apr 2019 08:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF9AE6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:32:28 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v1so2647284oif.12
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=bt6wWpJdybrxVqwerEg7eEw6uZTRVVYM53TvODhSPBc=;
        b=lC8Jl13WJZjdSo/SD8hLs4XupNuc/x+/6RJ389aPbYgvFAuuBPbrWnxIlUcIl3qukr
         JgVHWhYOwTvkmbAD/wEBhrcEBAoWu/aJwg3hBOqWQwFyUzBdnV8GmTO506i6vQssVhlR
         8GgnVcx1HiewFG64hL3RoXykPgsq1Je+MbtIEEriTj454uhPYHqRn8W73PQyUKIKTzGy
         vzimQHjsMsts/HLng1/hhlVNoVXiM3OL/fhVdmoYookrteF+hlrLISgZHcAi44Udd4k1
         /itJRu3G0K/0YyfWLJhlmBi2X8JDv9NwiKtRYWU1TRmZrZ5HoSaOTJgNqB+L1eE3ILh2
         D5LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWfsK/JiQEJl0ZhE/Oy46rg3gEeSQ3rlSbUgejpLOtTcJK6g7Xp
	pSy4mVxitk5cCJe09FOuyg5hi0PNLSPP1/zG0zaaOEnKn+E3zqIqYbAZFi0DA9ya/lprG3I/IrR
	Ohbp3u7lpgr/SQWyji8tEaL8XNmA62nsrcmvhEfsmxzUVqeSY9fAeOKum5bVAUdrtZA==
X-Received: by 2002:a05:6830:2144:: with SMTP id r4mr32009322otd.250.1554985948590;
        Thu, 11 Apr 2019 05:32:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzox/2ctWbt3iisKCSzwSEaRTMW5ZfjcMv+uAZka9Si9+0b2FA59lNca5HrKQRDBU9PhxvU
X-Received: by 2002:a05:6830:2144:: with SMTP id r4mr32009249otd.250.1554985947405;
        Thu, 11 Apr 2019 05:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554985947; cv=none;
        d=google.com; s=arc-20160816;
        b=yWlYktc/JthNfETTXQ2jfClZFpx87voY6yPr2H0NURBC3oKSd1bpz0hNMqP5e+vGpz
         MfuCmFr/CzgfOcL9m9mYF7Quv5COA1/BmdMcqSbQgCwJTe6O9PuoFTMc7oRJ7SG4mrOB
         4umNhkKiIsrBT4/7bxNopJAHPPZV+khUlYOuKJll54DtsUO/KZZZDUIJqHIZq87vQXvw
         vJLLLHYYJvnGq3oXvaRkRs8me/QOFxPT6QOdxugZDFqObjLDbsw3+xvReTg2OzNBpvcC
         vOW+rc+U6nOyLwg9dB/f0FuHGd3dVGSdGtqk9dxGcAX/XERT29DQU6Ehhs9AHbZeLoNx
         WE1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=bt6wWpJdybrxVqwerEg7eEw6uZTRVVYM53TvODhSPBc=;
        b=W11LBIF803FhM6YB9nh69q5AunBaWO+uR0I/jJlewU8V+5m6ex+9ZPCyexLAxR4r3u
         H0ycuSoqe90PeOyfJxxqOLRKyvZq3mt1fKWxw9zkfInEaph2z4opz5GjCPU8bt8N7lPD
         utIdFYEgbDcpB/BqjUmWyEatpVNh8sHPqaQ+26l4682edZ9A1VpDvxy5PeXwBimBZf+M
         wj+te/geRjnXRJySnf1zcJ8UZqcINCXbsCQFuUZJ90NuBopsJ1U9Uq6F0IOVzYy6f5G5
         j0ePVm3R9rQgSyU5EOtnUxLZ+IGNgG+bkhEZrsM0U4YpmEtsqu2gkbysfPTwEVhbifqP
         T0Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id q11si17315735otf.208.2019.04.11.05.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 7E4E0BFF5522A0FE345B;
	Thu, 11 Apr 2019 20:32:21 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Thu, 11 Apr 2019
 20:32:13 +0800
Subject: Re: [PATCH v3 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
To: Ingo Molnar <mingo@kernel.org>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-2-chenzhou10@huawei.com>
 <20190410070914.GA10935@gmail.com>
CC: <wangkefeng.wang@huawei.com>, <horms@verge.net.au>,
	<ard.biesheuvel@linaro.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <linux-kernel@vger.kernel.org>, <rppt@linux.ibm.com>,
	<linux-mm@kvack.org>, <takahiro.akashi@linaro.org>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>, <kexec@lists.infradead.org>,
	<tglx@linutronix.de>, <akpm@linux-foundation.org>,
	<linux-arm-kernel@lists.infradead.org>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <31b41dcc-0d16-d1d0-bff9-dec3e77515c1@huawei.com>
Date: Thu, 11 Apr 2019 20:32:11 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190410070914.GA10935@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On 2019/4/10 15:09, Ingo Molnar wrote:
> 
> * Chen Zhou <chenzhou10@huawei.com> wrote:
> 
>> In preparation for supporting more than one crash kernel regions
>> in arm64 as x86_64 does, move reserve_crashkernel_low() into
>> kexec/kexec_core.c.
>>
>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>> ---
>>  arch/x86/include/asm/kexec.h |  3 ++
>>  arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
>>  include/linux/kexec.h        |  1 +
>>  kernel/kexec_core.c          | 53 +++++++++++++++++++++++++++++++++++
>>  4 files changed, 64 insertions(+), 59 deletions(-)
> 
> No objections for this to be merged via the ARM tree, as long as x86 
> functionality is kept intact.

This patch has no affect on x86.

Thanks,
Chen Zhou

> 
> Thanks,
> 
> 	Ingo
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> 

