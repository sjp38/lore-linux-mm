Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D14EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEBDD218CD
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Sk2KAcpB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEBDD218CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DDE48E0003; Wed, 27 Feb 2019 03:25:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38E238E0001; Wed, 27 Feb 2019 03:25:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2593B8E0003; Wed, 27 Feb 2019 03:25:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE78E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:25:31 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h2so7633722wre.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 00:25:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:message-id
         :date:user-agent:mime-version:content-transfer-encoding
         :content-language;
        bh=/UPkz0WwtcL8bE1OiayFX/WKIUhxV4kqxfgR2z1/XR4=;
        b=TMmI9kAmHUV6kCtJSsxLlff59/7uorV/KrAd4rIRfIjspRBeiVjdJirhvVae7JyhqC
         CCOLVK6KZB/A84J8F3M5TTJqi7lewxn9OZTGsdmfoPHBZ+ectWUwBN3rZzEGZopwfNyy
         NgY/0U2eReyUp2wdpPvFqlsEJLOYFX2jJG//+0STaiJ8hAJax1DsiRHGhEmd5W5hRUrl
         DL8YmSQwOpCbsAsa19Xjj/Z9VnjkYdyGqoPsaePKmR6oiIPrjgfE3bTebpKuEQg0wD1L
         RUEzAEt+zdf4TIcN44u66g7M7llGzxs+vOQ40RGvNtjJni5TK7+O3rLyDlbMBiA4JQaw
         OOng==
X-Gm-Message-State: AHQUAuZ10S1dMM4Q/CBpKfxsad0y1lss3Kgi5r1vO3ZmAYEcytE+7qAy
	+XL35r9GuOd0mwE34TtPw6soInDHi8/HKbRiNAkp0UKh/muip2iX9432e3I/Lhu2Ypjsdg5m+zO
	SUFW6vir1RnNFHf6XuO8PTCt4r5x8PzetO/DXDbTEn3saHO2FBjfI/bvXNQKIPuk/IA==
X-Received: by 2002:a05:600c:224c:: with SMTP id a12mr1354277wmm.103.1551255931035;
        Wed, 27 Feb 2019 00:25:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVLXKgUrsjsVxIZwNFFdpPgJEzGbbN98W141DekEzytClwy4lcwwFJSSYiCcaVH8GpFcAo
X-Received: by 2002:a05:600c:224c:: with SMTP id a12mr1354214wmm.103.1551255929531;
        Wed, 27 Feb 2019 00:25:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551255929; cv=none;
        d=google.com; s=arc-20160816;
        b=L79AFmchC5hXGXhPdg0d213bU22JHV9a3JqfXJGFSsarbJdjUp6T2PQw7sKhVIOpjI
         AmOVhGW0o7Oo7cU71dvkftbtCimbBBuLTL1TOexOswsKsp6cNK8Lak3sGMWH4vFT7dp0
         iSL6LoKk7qcwNZmtS/7u1WVJHlvPVVzA0Hb3o0tGsJG1mHHD1W4R63O9caEw6gLbvSIX
         JjCPo6nh3oAV58dOAg0R3ojxdnu2Yn/2bfM7kr+vKiynCJ98nMwijYs1HW6opNVJFXaF
         0AAklO8STffZarDRX/WDo9GgjaRT+b7T0Gs61EeToxSIlnSmkiIIORfoom+RNPj77D8m
         kTwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:subject:cc:to:from:dkim-signature;
        bh=/UPkz0WwtcL8bE1OiayFX/WKIUhxV4kqxfgR2z1/XR4=;
        b=k276SSuXTnEwMyPTBQM02m+Tp6JXxvLVA0B1/2MtG/ueaDvEkRrat+Wkn+yn+LZ+05
         kXlcDel3MVHfAZzi7ensRU0U3AHc+ilvJiXbp8aHXGPjjvW9Fy5E33aRjr860J9X8W04
         9IosPUiMhYTbZSvQtO2pUw7Jz+LJZwqEFjlRZ2nRpKraZTIldKvzGw9RzRj1QQpp5KZ/
         0VbCFjdFWVaVy0IO+NTfHyXPt1ZuC/RCWmIa1atAKAKqJWmVjApM9X/nIGlTZbSxDmm3
         6s2RYU9oU/6/enmJP3rfeTdpUidkVppmltMpoYsgavuSbUk6HXaPnAjGk4W+dGMK64H9
         Y0TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Sk2KAcpB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f136si638115wme.149.2019.02.27.00.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 00:25:29 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Sk2KAcpB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 448TJl5nw3z9tySf;
	Wed, 27 Feb 2019 09:25:27 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Sk2KAcpB; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Y0pg6aSDFRow; Wed, 27 Feb 2019 09:25:27 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 448TJl4WPbz9tySd;
	Wed, 27 Feb 2019 09:25:27 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551255927; bh=/UPkz0WwtcL8bE1OiayFX/WKIUhxV4kqxfgR2z1/XR4=;
	h=From:To:Cc:Subject:Date:From;
	b=Sk2KAcpBKlWKabKx+a2QuMpVdmH/nVEZ5yF52y5E+HRUWX3xYEIeeO2jYX9ZyuKTl
	 cHDWZPePtubFbxdYeLOfOxjAFOxEBMqmlk1+A+lO7ORUdKXWzhR7aK0/j218LlEjZR
	 LxJIRj8BR/176Zc4NmxNC1DsjcVUB+Vl5rVABqdo=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 96D968B8B4;
	Wed, 27 Feb 2019 09:25:28 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id qY-R5Qmgzj6G; Wed, 27 Feb 2019 09:25:28 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 69AE18B754;
	Wed, 27 Feb 2019 09:25:28 +0100 (CET)
From: Christophe Leroy <christophe.leroy@c-s.fr>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Axtens <dja@axtens.net>, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com
Subject: BUG: KASAN: stack-out-of-bounds
Message-ID: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
Date: Wed, 27 Feb 2019 09:25:28 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With version v8 of the series implementing KASAN on 32 bits powerpc 
(https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), 
I'm now able to activate KASAN on a mac99 is QEMU.

Then I get the following reports at startup. Which of the two reports I 
get seems to depend on the option used to build the kernel, but for a 
given kernel I always get the same report.

Is that a real bug, in which case how could I spot it ? Or is it 
something wrong in my implementation of KASAN ?

I checked that after kasan_init(), the entire shadow memory is full of 0 
only.

I also made a try with the strong STACK_PROTECTOR compiled in, but no 
difference and nothing detected by the stack protector.

==================================================================
BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
Read of size 1 at addr c0ecdd40 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
Call Trace:
[c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
[c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
[c0e9dd10] [c089579c] memchr+0x24/0x74
[c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
[c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
[c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
--- interrupt: c0e9df00 at 0x400f330
     LR = init_stack+0x1f00/0x2000
[c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
[c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
[c0e9df50] [c0c16434] start_kernel+0x310/0x488
[c0e9dff0] [00003484] 0x3484

The buggy address belongs to the variable:
  __log_buf+0xec0/0x4020
The buggy address belongs to the page:
page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
flags: 0x1000(reserved)
raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
                                    ^
  c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
  c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

==================================================================
BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x600
Read of size 1 at addr f6f37de0 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1134
Call Trace:
[c0ff7d60] [c01fe808] print_address_description+0x6c/0x2b0 (unreliable)
[c0ff7d90] [c01fe4fc] kasan_report+0x13c/0x1ac
[c0ff7dd0] [c0d34324] pmac_nvram_init+0x1ec/0x600
[c0ff7ef0] [c0d31148] pmac_setup_arch+0x280/0x308
[c0ff7f20] [c0d2c30c] setup_arch+0x250/0x280
[c0ff7f50] [c0d26354] start_kernel+0xb8/0x4d8
[c0ff7ff0] [00003484] 0x3484


Memory state around the buggy address:
  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
                                                ^
  f6f37e00: 00 00 00 00 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
  f6f37e80: 00 00 01 f2 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

==================================================================
BUG: KASAN: stack-out-of-bounds in memchr+0xa0/0xac
Read of size 1 at addr c17cdd30 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1135
Call Trace:
[c179dc90] [c032fe28] print_address_description+0x64/0x2bc (unreliable)
[c179dcc0] [c033020c] kasan_report+0xfc/0x180
[c179dd00] [c115ef50] memchr+0xa0/0xac
[c179dd20] [c01297f8] msg_print_text+0xc8/0x67c
[c179ddd0] [c012bc8c] console_unlock+0x17c/0x818
[c179de40] [c012f420] vprintk_emit+0x188/0x1c4
--- interrupt: c179df30 at 0x400def0
     LR = init_stack+0x1ef0/0x2000
[c179de80] [c012fff0] printk+0xa8/0xcc (unreliable)
[c179df20] [c150b4b8] early_irq_init+0x38/0x108
[c179df50] [c14ef7f8] start_kernel+0x30c/0x530
[c179dff0] [00003484] 0x3484

The buggy address belongs to the variable:
  __log_buf+0xeb0/0x4020
The buggy address belongs to the page:
page:c6ebe9a0 count:1 mapcount:0 mapping:00000000 index:0x0
flags: 0x1000(reserved)
raw: 00001000 c6ebe9a4 c6ebe9a4 00000000 00000000 00000000 ffffffff 00000001
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  c17cdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  c17cdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >c17cdd00: 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00 f3 f3
                              ^
  c17cdd80: f3 f3 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  c17cde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

==================================================================
BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x228/0xae0
Read of size 1 at addr f6f37dd0 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1136
Call Trace:
[c1c37d50] [c03f7e88] print_address_description+0x6c/0x2b0 (unreliable)
[c1c37d80] [c03f7bd4] kasan_report+0x10c/0x16c
[c1c37dc0] [c19879b4] pmac_nvram_init+0x228/0xae0
[c1c37ef0] [c19826bc] pmac_setup_arch+0x578/0x6a8
[c1c37f20] [c19792bc] setup_arch+0x5f4/0x620
[c1c37f50] [c196f898] start_kernel+0xb8/0x588
[c1c37ff0] [00003484] 0x3484


Memory state around the buggy address:
  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >f6f37d80: 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00
                                          ^
  f6f37e00: 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2 00 00
  f6f37e80: 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00
==================================================================

==================================================================
BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x5ec
Read of size 1 at addr f6f37de0 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1137
Call Trace:
[c0fb7d60] [c01f8184] print_address_description+0x6c/0x2b0 (unreliable)
[c0fb7d90] [c01f7ed0] kasan_report+0x10c/0x16c
[c0fb7dd0] [c0d1dfe8] pmac_nvram_init+0x1ec/0x5ec
[c0fb7ef0] [c0d1ae90] pmac_setup_arch+0x280/0x308
[c0fb7f20] [c0d16138] setup_arch+0x250/0x280
[c0fb7f50] [c0d1032c] start_kernel+0xb8/0x4a4
[c0fb7ff0] [00003484] 0x3484


Memory state around the buggy address:
  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
                                                ^
  f6f37e00: 00 00 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
  f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
==================================================================

Thanks
Christophe

