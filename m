Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D89C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 713D420C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:11:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="O+kFrJ0q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 713D420C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E2768E0003; Wed, 27 Feb 2019 08:11:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 090CB8E0001; Wed, 27 Feb 2019 08:11:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E73408E0003; Wed, 27 Feb 2019 08:11:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1EB8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:11:51 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b197so1509847wmb.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 05:11:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eeD0A1ztSsVPgv1RXvJd9clgBtGzg/Xb1OyUlK3ASMM=;
        b=Q1Any3hPWPzz4bAaIUk3ZR8IcBll0Pm+NYLe2CZ9F0OvTqe830Mx7z8DC2EirdDp3Y
         /vSRjjg//uDecmb8aEfKP5j/Edbuhd2eWg6093EE/DI0HKCblycoY/TSmfHtu4neEFLd
         IQwtJWtjDFEONVuC5RaAymewZM3RlihKwMlcU16P2W9wETpF9KKtyQJHOIxYMPnwwdPs
         TZGnhgRnQHtMBXdq91qgWkxBOJCgj3JXlN/qwrMyroE7ieMbrqnnNgzNom9R5Tc/BPNM
         z+082/bKhJAhTwyHCjsAxpQjSDIM8XKnFeqT7lcWrVPyZKD01z3N7OQGSM9GD7mx+yOb
         84+g==
X-Gm-Message-State: APjAAAW6UAkF0PYN/Uf2L3Np+tfiCjdfurq7Ty78khuAtXZL/MLqXsKk
	JHVP0YAb2UDONltDaPxLQGOKgif8++lRlRRau8WUL1dZF3A+4tK98J9Pt7hPqBOEa5yfi3QYKg9
	u8mWlgQ4Wy8LzYyhQ6q8GFGGw5Fohsk5o5k+FaedZnwvjabDIsLivu/CqxChCDrtsFA==
X-Received: by 2002:adf:c752:: with SMTP id b18mr2395516wrh.105.1551273111122;
        Wed, 27 Feb 2019 05:11:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqxPve4ulWuhf8CBmzgo4DmyzvhCrORpadSM+lwFUDLXy5bc4id11Q9pY2bl9HNI0D0vw8Df
X-Received: by 2002:adf:c752:: with SMTP id b18mr2395445wrh.105.1551273110002;
        Wed, 27 Feb 2019 05:11:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551273109; cv=none;
        d=google.com; s=arc-20160816;
        b=GCb4uVtzeoBOP7z83EdhxDpfeP54uBsd295b4gNmwzVd+OctrBXEAIMPrZGSrnF6qL
         HxTrTHaWUA05Qy9RTfdmOZDEwvP6/xTmv7JZPG7TWt2ez6lCNnQcIssu84Z27f9Vqs5F
         84t+UCzvElpUqXcuhIbSeswIsoeQgU+l6xtmTaMzuJgwKbYMZLdDHR8lyUeI4D7nJX4Q
         apTkyJ8dZNRzXf8k82QW4XDD979GAErdOoqtgRDgLRPCJr/vRGZu6TnbrgcBO5O5MRj1
         SirKW694kb+/ciV9so+Hsv4Yzv09RdxHcBOtI2Rg2aqZpB8Ga0Br3GdsMJ0eNq+1N7WI
         WEFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=eeD0A1ztSsVPgv1RXvJd9clgBtGzg/Xb1OyUlK3ASMM=;
        b=NnejlGJgPL6PR9dlQj/ELYytVw8b8n6tZiNvGGQ4ea+veX+npsWdq5BKjaOaI60SxT
         Nv91045AyTIdxpXzxJo0IYX9+QJKMIUaxnA3Xzw9IFIPHNVup4s29hsqUWFhgVnEBNy1
         vstgg8j1SeM6Thjl1qeEaYrfBRDG8+ALengQQ+OCm26fhOWadOQs6qK6S2T5oT0/+c6U
         KimyYk/lC4AnQTLPTs08lT+XR2lPdPA607sYBJAYJyrfkf9bhfTB/lztyAvzwIsR9lAT
         SxQDlCBztSF8nA/jdtsvodhGs5QjIIsFyUZoqwzp+X9KnaVTRBnJv/oBo0hW2aKZGEab
         DmYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=O+kFrJ0q;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id j15si1180865wmh.198.2019.02.27.05.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 05:11:49 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=O+kFrJ0q;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 448bg80zq1z9v0G5;
	Wed, 27 Feb 2019 14:11:48 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=O+kFrJ0q; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Bn9FE8sDU_m0; Wed, 27 Feb 2019 14:11:48 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 448bg76r1Rz9v0G4;
	Wed, 27 Feb 2019 14:11:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551273108; bh=eeD0A1ztSsVPgv1RXvJd9clgBtGzg/Xb1OyUlK3ASMM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=O+kFrJ0ql/gtdlWvLbkSXJ8v6SZAseclFls76nVC0fgaHsN4BplxkjES/xQLTIOzL
	 f3NbqLW7qta5pJ92xTP9rClAAInbNLde8Pcvn75ydRMumxWHx1zP9pR//rqW9NBTo+
	 6rZfPP82uXXL1xamtpZJa4AJ+LXq7j2TKskeG9dg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 4C47D8B8D3;
	Wed, 27 Feb 2019 14:11:49 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id GnU3oP8ckzIa; Wed, 27 Feb 2019 14:11:49 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 200298B8D2;
	Wed, 27 Feb 2019 14:11:49 +0100 (CET)
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Axtens <dja@axtens.net>, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
 <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <15a40476-2852-cf5a-0982-d899dd79d9c1@c-s.fr>
Date: Wed, 27 Feb 2019 14:11:49 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 27/02/2019 à 10:19, Andrey Ryabinin a écrit :
> 
> 
> On 2/27/19 11:25 AM, Christophe Leroy wrote:
>> With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
>>
>> Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
>>
>> Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
>>
>> I checked that after kasan_init(), the entire shadow memory is full of 0 only.
>>
>> I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
>>
>> ==================================================================
>> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
>> Read of size 1 at addr c0ecdd40 by task swapper/0
>>
>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
>> Call Trace:
>> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
>> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
>> [c0e9dd10] [c089579c] memchr+0x24/0x74
>> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
>> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
>> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
>> --- interrupt: c0e9df00 at 0x400f330
>>      LR = init_stack+0x1f00/0x2000
>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
>> [c0e9dff0] [00003484] 0x3484
>>
>> The buggy address belongs to the variable:
>>   __log_buf+0xec0/0x4020
>> The buggy address belongs to the page:
>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>> flags: 0x1000(reserved)
>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
>> page dumped because: kasan: bad access detected
>>
>> Memory state around the buggy address:
>>   c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>>                                     ^
>>   c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>>   c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>> ==================================================================
>>
> 
> This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is
> 	"The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
>   which is printed by following code:
> 	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
> 		pr_err("The buggy address belongs to the variable:\n");
> 		pr_err(" %pS\n", addr);
> 	}
> 
> So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
> KASAN with stack instrumentation significantly increases stack usage.
> 

I get the above with THREAD_SHIFT set to 13 (default value).
If increasing it to 14, I get the following instead. That means that in 
that case the problem arises a lot earlier in the boot process (but 
still after the final kasan shadow setup).

==================================================================
BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1f8/0x5d0
Read of size 1 at addr f6f37de0 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1143
Call Trace:
[c0e9fd60] [c01c43c0] print_address_description+0x164/0x2bc (unreliable)
[c0e9fd90] [c01c46a4] kasan_report+0xfc/0x180
[c0e9fdd0] [c0c226d4] pmac_nvram_init+0x1f8/0x5d0
[c0e9fef0] [c0c1f73c] pmac_setup_arch+0x298/0x314
[c0e9ff20] [c0c1ac40] setup_arch+0x250/0x268
[c0e9ff50] [c0c151dc] start_kernel+0xb8/0x488
[c0e9fff0] [00003484] 0x3484


Memory state around the buggy address:
  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
                                                ^
  f6f37e00: 00 00 01 f4 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
  f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
==================================================================

Christophe

