Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13DF7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:35:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A69152133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:35:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="FOgXekoF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A69152133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568278E0004; Wed, 27 Feb 2019 07:35:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 518238E0001; Wed, 27 Feb 2019 07:35:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E2FB8E0004; Wed, 27 Feb 2019 07:35:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D90018E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 07:35:57 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 92so6738494wrb.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:35:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yHLQO5S2trM0ZdRZxe0F+kRx4XmE+BUHMNxf2X0sScM=;
        b=l2mpQ92qtyf73VRhGxolpulSnQQdeEdJBVKV7793X/akR+hrw0t4kU4t2x5gYvNkDV
         79vOnrwYqXFK80XzPwIjF/5mbbL2g9F4XeJgcl/9u3qgRXZs7xed9YUSNavQlb23F0cr
         niot6FME75VPQTyRasejVhNCUPEmhi0fq8zhgyJE11k5ZSYGIahVU84OFbwEkkknLE4P
         NZzPih+xvswQYixTpsjG75V6qXb4bwgqb0pEwAsArbcqnUk2ubJktkh09sTBxBMjPB5T
         wwzWJJkyDOUh/ZuEuOsv2tQxOWDT+wqZyYPiGXXrqQ89qQyBY1KSbTAdNX6KKAAzZaHG
         fxGg==
X-Gm-Message-State: APjAAAWsPfWHsBIuMo2NNugRkXgP7lRwJW7iH4a748QX8UcnLzA8WPtn
	W9NYs4Ae0u8SKNcYPrj51K1VvDoq7V70h8CzQix+TMLyFctgviEBpnYj1bH6difW4mp+WQKnwrm
	onM9JIAMYJwT+empdYpwXBH+gjyuxd5n91t5k6+JhJ5HskrmoQVN26nP0wKkWeySKOA==
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr2221203wrx.281.1551270957437;
        Wed, 27 Feb 2019 04:35:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqzpe7EzQZryqeveOCSO15pc2oPmSccFcOaYax94ywIKEj0eAOvDF0m0psj8go8QXpmXEHh7
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr2221132wrx.281.1551270956109;
        Wed, 27 Feb 2019 04:35:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551270956; cv=none;
        d=google.com; s=arc-20160816;
        b=OKCE8gXl/6jYHI7YM3GmbQwdZkS8Vbgb87jd5dkEKjIbwo+b6UBj87pzbPD74Hi/8c
         4WkIXGF7v+fF4dYiPXQDCD33QFsOOpbX+7FnsEisoqDcQ8PlxQAw98ln3xPOArvyzh7G
         eNIlgU/2jTZ4Jbbsh3hmr1Krjmigzr60+sHxgn149F7PBMaKxTBag7OLTGca2sZ1sbp8
         8K7V/DwfZPhmPNbqAv1DwHviiqd1D8dSaMaw5NKJiKAiQyvW33Pnhmmdv3wlpOuYXiHa
         T4aWNS5XFhup7C7+lvbPqhm8NBXwbXtESrBQgktPpHACGIkcuSBhqh9KOGgGkEM+8nnZ
         tclA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=yHLQO5S2trM0ZdRZxe0F+kRx4XmE+BUHMNxf2X0sScM=;
        b=BEtQZr0K/32BEZTbSmODl0CC+q2aYhvYqnRqR/VaasVpqOq8fe64wdyzrAOSs51c+l
         yJ2K0SO1mudoUAxH3db7RmOfu2XkEkv0mc3+f4cgo+sRWBwWTFNXap0UDq21kxU1gOTy
         m0ZJDGVU5J6af2fI/vxJwZweRLOawHP3iU6ujD/5dU425rNloNqtwxgO3NIWJh4Ct/yt
         wErbBZFLcgMEk6QamgDAkHcyW+TkaJVfQMmAHeGmXCHesOd7TumsZ/DvkzkutXKPN66Z
         8h6kRZOYhHIFS50z3dkrkdP+ziOQnKX3+0ywNklcwQK1xdPn252c3A8ezeYEdKzD/zcK
         j6aA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FOgXekoF;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id m1si1300179wml.180.2019.02.27.04.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 04:35:56 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FOgXekoF;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 448Zsk1RHbz9v0N2;
	Wed, 27 Feb 2019 13:35:54 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=FOgXekoF; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Y-qZrmHsPwft; Wed, 27 Feb 2019 13:35:54 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 448Zsk0Hq6z9v0N0;
	Wed, 27 Feb 2019 13:35:54 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551270954; bh=yHLQO5S2trM0ZdRZxe0F+kRx4XmE+BUHMNxf2X0sScM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=FOgXekoFv/oWCN5vtiitqiZ6/Wk9ZfFOTMCzR1PjSrMwDCtmo+0bPDJX7NZPG6/iA
	 5JpgxoFoS6CXEP2hz2CCfxUUXwDqFeJYt+0qnG5L53XeqHQ6ViZkF5KET0QKJFvrvy
	 OH+DxLNF7PTAgOjZ485QXqf2gdvB6BZRd4qCP9aU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 506648B8C1;
	Wed, 27 Feb 2019 13:35:55 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id fgoSy1nyqlSN; Wed, 27 Feb 2019 13:35:55 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0A9EC8B754;
	Wed, 27 Feb 2019 13:35:55 +0100 (CET)
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Daniel Axtens <dja@axtens.net>,
 Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org,
 kasan-dev <kasan-dev@googlegroups.com>
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
 <CACT4Y+bTBGfsLq+bE9-no8sj8yvrkPN6iaELZMi7DX4Vr59zrA@mail.gmail.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <5c8058fe-ac6a-2b50-3d52-fe89bb48b6f5@c-s.fr>
Date: Wed, 27 Feb 2019 12:35:35 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bTBGfsLq+bE9-no8sj8yvrkPN6iaELZMi7DX4Vr59zrA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/27/2019 08:34 AM, Dmitry Vyukov wrote:
> On Wed, Feb 27, 2019 at 9:25 AM Christophe Leroy
> <christophe.leroy@c-s.fr> wrote:
>>
>> With version v8 of the series implementing KASAN on 32 bits powerpc
>> (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309),
>> I'm now able to activate KASAN on a mac99 is QEMU.
>>
>> Then I get the following reports at startup. Which of the two reports I
>> get seems to depend on the option used to build the kernel, but for a
>> given kernel I always get the same report.
>>
>> Is that a real bug, in which case how could I spot it ? Or is it
>> something wrong in my implementation of KASAN ?
> 
> What is the state of your source tree?
> Please pass output through some symbolization script, function offsets
> are not too useful.
> There was some in scripts/ dir IIRC, but here is another one (though,
> never tested on powerpc):
> https://github.com/google/sanitizers/blob/master/address-sanitizer/tools/kasan_symbolize.py

I get the following. It doesn't seem much interesting, does it ?

==================================================================
BUG: KASAN: stack-out-of-bounds in[<        none        >] 
memchr+0x24/0x74 lib/string.c:958
Read of size 1 at addr c0ecdd40 by task swapper/0

CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1142
Call Trace:
[c0e9dca0] [c01c42c0] print_address_description+0x64/0x2bc (unreliable)
[c0e9dcd0] [c01c46a4] kasan_report+0xfc/0x180
[c0e9dd10] [c0895150] memchr+0x24/0x74
[c0e9dd30] [c00a9e58] msg_print_text+0x124/0x574
[c0e9dde0] [c00ab730] console_unlock+0x114/0x4f8
[c0e9de40] [c00adc80] vprintk_emit+0x188/0x1c4
[c0e9de80] [c00ae3e4] printk+0xa8/0xcc
[c0e9df20] [c0c27e44] early_irq_init+0x38/0x108
[c0e9df50] [c0c15434] start_kernel+0x310/0x488
[c0e9dff0] [00003484] 0x3484

The buggy address belongs to the variable:
[<        none        >] __log_buf+0xec0/0x4020 
arch/powerpc/kernel/head_32.S:?
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


Christophe

> 
> 
> 
>> I checked that after kasan_init(), the entire shadow memory is full of 0
>> only.
>>
>> I also made a try with the strong STACK_PROTECTOR compiled in, but no
>> difference and nothing detected by the stack protector.
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
>>       LR = init_stack+0x1f00/0x2000
>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
>> [c0e9dff0] [00003484] 0x3484
>>
>> The buggy address belongs to the variable:
>>    __log_buf+0xec0/0x4020
>> The buggy address belongs to the page:
>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>> flags: 0x1000(reserved)
>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
>> page dumped because: kasan: bad access detected
>>
>> Memory state around the buggy address:
>>    c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   >c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>>                                      ^
>>    c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>>    c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>> ==================================================================
>>
>> ==================================================================
>> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x600
>> Read of size 1 at addr f6f37de0 by task swapper/0
>>
>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1134
>> Call Trace:
>> [c0ff7d60] [c01fe808] print_address_description+0x6c/0x2b0 (unreliable)
>> [c0ff7d90] [c01fe4fc] kasan_report+0x13c/0x1ac
>> [c0ff7dd0] [c0d34324] pmac_nvram_init+0x1ec/0x600
>> [c0ff7ef0] [c0d31148] pmac_setup_arch+0x280/0x308
>> [c0ff7f20] [c0d2c30c] setup_arch+0x250/0x280
>> [c0ff7f50] [c0d26354] start_kernel+0xb8/0x4d8
>> [c0ff7ff0] [00003484] 0x3484
>>
>>
>> Memory state around the buggy address:
>>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>>                                                  ^
>>    f6f37e00: 00 00 00 00 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>>    f6f37e80: 00 00 01 f2 00 00 00 00 00 00 00 00 00 00 00 00
>> ==================================================================
>>
>> ==================================================================
>> BUG: KASAN: stack-out-of-bounds in memchr+0xa0/0xac
>> Read of size 1 at addr c17cdd30 by task swapper/0
>>
>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1135
>> Call Trace:
>> [c179dc90] [c032fe28] print_address_description+0x64/0x2bc (unreliable)
>> [c179dcc0] [c033020c] kasan_report+0xfc/0x180
>> [c179dd00] [c115ef50] memchr+0xa0/0xac
>> [c179dd20] [c01297f8] msg_print_text+0xc8/0x67c
>> [c179ddd0] [c012bc8c] console_unlock+0x17c/0x818
>> [c179de40] [c012f420] vprintk_emit+0x188/0x1c4
>> --- interrupt: c179df30 at 0x400def0
>>       LR = init_stack+0x1ef0/0x2000
>> [c179de80] [c012fff0] printk+0xa8/0xcc (unreliable)
>> [c179df20] [c150b4b8] early_irq_init+0x38/0x108
>> [c179df50] [c14ef7f8] start_kernel+0x30c/0x530
>> [c179dff0] [00003484] 0x3484
>>
>> The buggy address belongs to the variable:
>>    __log_buf+0xeb0/0x4020
>> The buggy address belongs to the page:
>> page:c6ebe9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>> flags: 0x1000(reserved)
>> raw: 00001000 c6ebe9a4 c6ebe9a4 00000000 00000000 00000000 ffffffff 00000001
>> page dumped because: kasan: bad access detected
>>
>> Memory state around the buggy address:
>>    c17cdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    c17cdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   >c17cdd00: 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00 f3 f3
>>                                ^
>>    c17cdd80: f3 f3 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    c17cde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>> ==================================================================
>>
>> ==================================================================
>> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x228/0xae0
>> Read of size 1 at addr f6f37dd0 by task swapper/0
>>
>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1136
>> Call Trace:
>> [c1c37d50] [c03f7e88] print_address_description+0x6c/0x2b0 (unreliable)
>> [c1c37d80] [c03f7bd4] kasan_report+0x10c/0x16c
>> [c1c37dc0] [c19879b4] pmac_nvram_init+0x228/0xae0
>> [c1c37ef0] [c19826bc] pmac_setup_arch+0x578/0x6a8
>> [c1c37f20] [c19792bc] setup_arch+0x5f4/0x620
>> [c1c37f50] [c196f898] start_kernel+0xb8/0x588
>> [c1c37ff0] [00003484] 0x3484
>>
>>
>> Memory state around the buggy address:
>>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00
>>                                            ^
>>    f6f37e00: 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2 00 00
>>    f6f37e80: 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00
>> ==================================================================
>>
>> ==================================================================
>> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x5ec
>> Read of size 1 at addr f6f37de0 by task swapper/0
>>
>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1137
>> Call Trace:
>> [c0fb7d60] [c01f8184] print_address_description+0x6c/0x2b0 (unreliable)
>> [c0fb7d90] [c01f7ed0] kasan_report+0x10c/0x16c
>> [c0fb7dd0] [c0d1dfe8] pmac_nvram_init+0x1ec/0x5ec
>> [c0fb7ef0] [c0d1ae90] pmac_setup_arch+0x280/0x308
>> [c0fb7f20] [c0d16138] setup_arch+0x250/0x280
>> [c0fb7f50] [c0d1032c] start_kernel+0xb8/0x4a4
>> [c0fb7ff0] [00003484] 0x3484
>>
>>
>> Memory state around the buggy address:
>>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>>                                                  ^
>>    f6f37e00: 00 00 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>>    f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
>> ==================================================================
>>
>> Thanks
>> Christophe

