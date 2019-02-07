Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83152C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 12:58:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DF2321904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 12:58:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SJqJXjIB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DF2321904
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C1E38E002A; Thu,  7 Feb 2019 07:58:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 470E28E0002; Thu,  7 Feb 2019 07:58:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389BA8E002A; Thu,  7 Feb 2019 07:58:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5EF68E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 07:58:45 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so7431440pll.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 04:58:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rRWwt4URCRXcwIZxbYDkHZAEZxjPcHH4qziRDx6ay7I=;
        b=rdIC2bgdO1wqic3s8xAB2pob3GoQfr5UJ1ENmX1cNOUBCbCNPq3fIhBa85qV5rNDSK
         URaiI14Bve9Mc4ddNPLvbnOMnTsOzZ0iDvfxgaFoI4mrmhAClwtCNw0FEBIQaA+zlwF0
         Em2dJL+F6NjIeTZjb61T5mqCTrVStx35yw0gcF/48nGnp/bd9WwBL6uvwO2LHmd4fg1B
         yL3O2JmVJCWgxbKg0TQzouQnbbuLPpETa10SYU4sEornslsMsi4xn0Uex+hyDDHFZ3D/
         inyyRxKvyAiU+ugel0Kb+T/TmbbuJmax/9qyQEAy5z0dbft1puHJrWIwTQYFqrQ5/28k
         eFcw==
X-Gm-Message-State: AHQUAuYAFE/ra5uncduO+LdPlQfRXnXCgnfBKeO8VnHwu6pm/Y1v5CQm
	eYJCFL8ZwH3ZHaSusAyyAi2bAfhDgUwBzXMPOHDcDBJXAIfMklAV9CuCEYEcF+unpRAfx5PpvCH
	jDDnDDpYKbj32V9giix6jdFzgJihYkHLpjZJwZn2JcPOYxY0UgY5tdFjPI2vb2UAl5IZFySt1nk
	1k8rwaTyHIvj4AUSav6iK3Pxr7N6m8NqgsjKTQhtYjAAzcclLXCTB9PuCcpgTcCKaSt55E6G3DD
	kT87XhLNcL6fbbKJZoaETuTZlerKxmkWbfZO16aoVIoQE6W1H6RVlREGLEFd5oV/OSfFxE9nk8z
	tnd/oI6FrvKkWz+QC+vf6YvJr0e/VuJwTyZrbSfOg/i4cunZV7RaWMv5vAsTZtw7xd2clqET7xM
	q
X-Received: by 2002:a65:5301:: with SMTP id m1mr14212386pgq.90.1549544325373;
        Thu, 07 Feb 2019 04:58:45 -0800 (PST)
X-Received: by 2002:a65:5301:: with SMTP id m1mr14212341pgq.90.1549544324274;
        Thu, 07 Feb 2019 04:58:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549544324; cv=none;
        d=google.com; s=arc-20160816;
        b=AHa7sQ2lffZtIQaum5g160FQg3ldvptZF1FnZBRSn2fyWDnH/3u3q7tJFnIao8m5c5
         ltANoSgKonAt6jOSG5Du0sdJsW/iHzLWhGAHE/8Rm/78cvLYbpPk+l++9Jgctbef1FvC
         yWax9NlarjY2iPaJrF067jN+QbFMsEul7Q5nIEVmLlkcAHv8qs391hxQQNNNIaw1iy84
         NE74lR0XrNb3mb5gEakB17ae3o3w05JdxrlUF0C75e+oDCPRVCS38CRahMLFRJtpTD1E
         j80M4pRDH3iW1wBbi455PSiZcsnTMhXBid30XdlLEYIrnHHABWY7e7PpKYVi1R4sQF86
         QtNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rRWwt4URCRXcwIZxbYDkHZAEZxjPcHH4qziRDx6ay7I=;
        b=L89w9QGpc555cg1px+pXe7JSigrS21WZpg91cX1PyREv1nZ5+fPy0fmL6AaGV/S+D5
         3R365N5iUtJcGnb8k0Fj5SREugMTcxtcOwac0MxUkbTDZsn2LG6GsYXTs2AlXtVnPT+2
         B0KhP3JPWk8qMXGFEbVdcrB0f9Vf7JEXj1zy5JnCwW1qrjMUvIC469NJ+f3etdCYhU3H
         RwArw8EJY/33n/MERfofw6vNswB6cIJEGf9gwxd9qwQH8bF7nIYzmtSGGrWJzdMKnYlY
         VEZZ2/eoKj6goucJTTw6RGmfXaqhB23JUNQWgdEKmI8cmDqBFE97HZQU7E47OyWkprFz
         rBiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SJqJXjIB;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y22sor6846260pfn.9.2019.02.07.04.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 04:58:44 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SJqJXjIB;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rRWwt4URCRXcwIZxbYDkHZAEZxjPcHH4qziRDx6ay7I=;
        b=SJqJXjIBwzbuiMMx3cdyzQxG2h+pkW8Nqnxt/dW6chSPurhZN+GxpGd2H01aKvryWX
         /7o/c649L3gMxZ/4X+1jK0bprBzSouam0GMBRDQ5skeMM+Tr26A57RLVPiS8+HibBdv5
         DUlwUrgLG1VjrxiPhxli+/qDqdDDvZh9jLQWVY8ZYzhenoJl1LWIeXbPaHv6X13u1MZr
         bMiLBO+p3eQDTjD/M48KQtxZkNpZttRLLWcZ5YZJTWT410noBnrxDJUlIhpdPz+kv+Vp
         R1/uGQ3E/9kAdTtvo29gBWLFW9Ljte4ORSfdyYVq11iUJhJy70WQw3hfEMeq1iMlwOEu
         SsYw==
X-Google-Smtp-Source: AHgI3IYq/RozyymCMYCqwKU17RYvcd7MFhkheCrs+eM9ALWLG/mli/pClahJ31igwZ5DN5iPyTD95MOutF5xsXHzPSU=
X-Received: by 2002:a62:5c1:: with SMTP id 184mr15885896pff.165.1549544323426;
 Thu, 07 Feb 2019 04:58:43 -0800 (PST)
MIME-Version: 1.0
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
In-Reply-To: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 7 Feb 2019 13:58:32 +0100
Message-ID: <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
Subject: Re: CONFIG_KASAN_SW_TAGS=y NULL pointer dereference at freelist_dereference()
To: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 5:04 AM Qian Cai <cai@lca.pw> wrote:
>
> The kernel was compiled by clang-7.0.1 on a ThunderX2 server, and it fails to
> boot. CONFIG_KASAN_GENERIC=y works fine.

Hi Qian,

Could you share the kernel commit id and .config that you use?

Thanks!

>
> deactivate_slab+0x84/0x6ac:
> freelist_dereference at mm/slub.c:262
> (inlined by) get_freepointer at mm/slub.c:268
> (inlined by) deactivate_slab at mm/slub.c:2056
>
> /* Returns the freelist pointer recorded at location ptr_addr. */
> static inline void *freelist_dereference(const struct kmem_cache *s,
>                                          void *ptr_addr)
> {
>         return freelist_ptr(s, (void *)*(unsigned long *)(ptr_addr),
>                             (unsigned long)ptr_addr);
> }
>
> [    0.000000] Memory: 3259968K/100594752K available (15548K kernel code, 12360K
> rwdata, 4096K rodata, 25536K init, 27244K bss, 7444672K reserved, 0K cma-reserved)
> [    0.000000] Unable to handle kernel NULL pointer dereference at virtual
> address 0000000000000078
> [    0.000000] Mem abort info:
> [    0.000000]   ESR = 0x96000005
> [    0.000000]   Exception class = DABT (current EL), IL = 32 bits
> [    0.000000]   SET = 0, FnV = 0
> [    0.000000]   EA = 0, S1PTW = 0
> [    0.000000] Data abort info:
> [    0.000000]   ISV = 0, ISS = 0x00000005
> [    0.000000]   CM = 0, WnR = 0
> [    0.000000] [0000000000000078] user address but active_mm is swapper
> [    0.000000] Internal error: Oops: 96000005 [#1] SMP
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc5+ #6
> [    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)
> [    0.000000] pc : deactivate_slab+0x84/0x6ac
> [    0.000000] lr : deactivate_slab+0x1cc/0x6ac
> [    0.000000] sp : ffff100012cf7be0
> [    0.000000] x29: ffff100012cf7cc0 x28: ffff1000114e4f00
> [    0.000000] x27: ffff1000114e4f20 x26: ffff1000114e4f08
> [    0.000000] x25: ffff1000114e5078 x24: fb00000000000000
> [    0.000000] x23: ffff7fe002080008 x22: ffff808abb5b72d0
> [    0.000000] x21: ffff7fe002080020 x20: ffff7fe002080028
> [    0.000000] x19: ffff7fe002080000 x18: ffff1000148a5538
> [    0.000000] x17: 000000000000001b x16: 0000000000000000
> [    0.000000] x15: 007ffffffc000201 x14: 04ff80082000fa80
> [    0.000000] x13: 0000000080660002 x12: 0000000080660003
> [    0.000000] x11: 4582a03bdc147ab9 x10: ffff100012d31c90
> [    0.000000] x9 : fb00000000000078 x8 : ffff100012d31c80
> [    0.000000] x7 : cccccccccccccccc x6 : ffff1000105d8db8
> [    0.000000] x5 : 0000000000000000 x4 : 0000000000000000
> [    0.000000] x3 : ffff808abb5b72d0 x2 : 04ff800820000580
> [    0.000000] x1 : ffff7fe002080000 x0 : ffff1000114e4f00
> [    0.000000] Process swapper (pid: 0, stack limit = 0x(____ptrval____))
> [    0.000000] Call trace:
> [    0.000000]  deactivate_slab+0x84/0x6ac
> [    0.000000]  ___slab_alloc+0x648/0x6fc
> [    0.000000]  kmem_cache_alloc_node+0x408/0x538
> [    0.000000]  __kmem_cache_create+0x20c/0x6a8
> [    0.000000]  create_boot_cache+0x68/0xac
> [    0.000000]  kmem_cache_init+0xb0/0x19c
> [    0.000000]  start_kernel+0x4b4/0xac4
> [    0.000000] Code: 14000057 b9400369 f940032b 8b090309 (f940012a)
> [    0.000000] ---[ end trace 54ad7e55e4749a96 ]---
> [    0.000000] Kernel panic - not syncing: Fatal exception
> [    0.000000] ---[ end Kernel panic - not syncing: Fatal exception ]---
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/b1d210ae-3fc9-c77a-4010-40fb74a61727%40lca.pw.
> For more options, visit https://groups.google.com/d/optout.

