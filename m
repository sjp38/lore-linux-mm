Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 148E9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C906E20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:18:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C906E20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64F538E0003; Wed, 27 Feb 2019 04:18:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FFC58E0001; Wed, 27 Feb 2019 04:18:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5177E8E0003; Wed, 27 Feb 2019 04:18:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC74A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:18:50 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id c7so2654342ljj.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:18:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pOYadiltrD0/YWqxSUuRjc8ojv+rDm60na8tpklIEJU=;
        b=MS7hvqnegvcqiqVSKhT0U8WrFH6wiBdcJXfWex+xpKY68O+v3JyB51ZIZHKNaE2uzp
         k5TXipfFW3PH4mhKBcqcnKjQZ8kx9c+WoK7qEj6v0cTN+1Uywp0hhIvkE3vesGvykQ5W
         Hqt6uArEPn7Jzv7O738nuyTFWCX08gWTAy6mKy+dte5VPpr22bWnpQY0x8aONLzh5hbB
         Vpo1hqqKxn9LIbRVNgvN8ebroe25OKVOnMf374XHUWTsg361mP8aszN2D7p6LrSOmeQm
         /NH4SBgBcieobp6WqGa1iHtD9pOnWonCdrD0fcU8nlHZlcM9y9Bn6LhA/r6WdRqE2NtS
         irEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZG/b65BrEfRDPzCHUJ/2U95cEZToxHyVub/v3JLH1idCZtW00l
	AxoEcL0XTChilHNI+KnfoUQgd3jIvM+CrFqNpGYLSSMDfiNu/wK5FRqBIYGlgnNUZx4f3Yt+ZU2
	NXC7NOf8aMu7YETFL3BB8vmRXl2tqwo7dKP+GnKDOAqDQcbSnJbh43x40B53XZvG25Q==
X-Received: by 2002:a19:4848:: with SMTP id v69mr226012lfa.35.1551259130066;
        Wed, 27 Feb 2019 01:18:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6x4dG7JrzbaNGb2ovucd3j9CKxYVX7KaJFsuUQvYHNcHG8ZrnyAenGy5MwW2pY0X5Pqqn
X-Received: by 2002:a19:4848:: with SMTP id v69mr225961lfa.35.1551259128977;
        Wed, 27 Feb 2019 01:18:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551259128; cv=none;
        d=google.com; s=arc-20160816;
        b=YBbJKmVZG8k27i98dCq4nsgVf/8Xxcaj7IS6p+4gb4WixpO9797L/DKfnLmp6Qqk4c
         Euf0quA007dBEg/y7Fd26jyvUTpeAnDhsmKzYMuNFDIDn4uF8TvGl3VTyTd+Clm/MKUK
         T9EO75Y+LlL/ZTOmRjBPlCke5DTPcri3AI6iZv7LX8rFLhHHV4Yafo6WGsscjQXsdNdc
         Xj3CweAYtPD2kX7bvhWfkWXOzjXMb1lQaOO0FC//Bre1T1nE8KqRiJcA8WSpJtiGF352
         sSZwZm5v69q4Xz1gV0fd0YnnzEUbFvHzxdtrBqhH6sMNfndp3knewT88U0LRBsvaelCt
         +PwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=pOYadiltrD0/YWqxSUuRjc8ojv+rDm60na8tpklIEJU=;
        b=ffJm5RItflNQ5DO5N7Fn6HWuAqR+Aerdowb+zE/MvdlMWgflOcCCoabEh0RqI+qo+V
         vnkNYZa95sF6U+QtrXYnF7F/RBKW6i84f4RkqxeCZChH8rEJsX/9qHleYcUfe9uFH8Z8
         dRBAFsRiY4xLsxq2nRoWJqFheTH4trX2PawFUQlql/hZuMEIC7AZLFfJXRPRhMOQ8n5f
         FwN04KVit7Yz0LrCZ0Fsu+QpmYte6W+htuw6pJi1Qu96iIbh2QAY+/3KcHlvYeTyVxYN
         jVlLZplczj/Qf3Kgy2YDKXAdZprfAvxc7XaT/vArAYYxLSysaSG63NBHlRysiLrJ2okP
         bMEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f23si6265237lfh.125.2019.02.27.01.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 01:18:48 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gyvMU-00037a-1i; Wed, 27 Feb 2019 12:18:46 +0300
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Christophe Leroy <christophe.leroy@c-s.fr>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Axtens <dja@axtens.net>, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
Date: Wed, 27 Feb 2019 12:19:04 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/27/19 11:25 AM, Christophe Leroy wrote:
> With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
> 
> Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
> 
> Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
> 
> I checked that after kasan_init(), the entire shadow memory is full of 0 only.
> 
> I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
> 
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
> Read of size 1 at addr c0ecdd40 by task swapper/0
> 
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
> Call Trace:
> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
> [c0e9dd10] [c089579c] memchr+0x24/0x74
> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
> --- interrupt: c0e9df00 at 0x400f330
>     LR = init_stack+0x1f00/0x2000
> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
> [c0e9dff0] [00003484] 0x3484
> 
> The buggy address belongs to the variable:
>  __log_buf+0xec0/0x4020
> The buggy address belongs to the page:
> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> flags: 0x1000(reserved)
> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
> page dumped because: kasan: bad access detected
> 
> Memory state around the buggy address:
>  c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>                                    ^
>  c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>  c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
> 

This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is 
	"The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
 which is printed by following code:
	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
		pr_err("The buggy address belongs to the variable:\n");
		pr_err(" %pS\n", addr);
	}

So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
KASAN with stack instrumentation significantly increases stack usage.

