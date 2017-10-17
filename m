Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 723F66B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:53:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p46so782923wrb.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:53:33 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id a84si6974619wmc.144.2017.10.17.05.53.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 05:53:31 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 00/11] KASan for arm
Date: Tue, 17 Oct 2017 12:41:49 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CAEB@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <26660524-3b0a-c634-e8ce-4ba7e10c055d@gmail.com>
 <bb809843-4fb8-0827-170e-26efde0eb37f@gmail.com>
 <44c86924-930b-3eff-55b8-b02c9060ebe3@gmail.com>
 <4b7b2b3c-cba9-d8ab-72a7-119bd5fae65d@redhat.com>
 <20171011225805.GY20805@n2100.armlinux.org.uk>
In-Reply-To: <20171011225805.GY20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Laura Abbott <labbott@redhat.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Zengweilin <zengweilin@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dailei <dylix.dailei@huawei.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, Jiazhenghua <jiazhenghua@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Heshaoliang <heshaoliang@huawei.com>

On 10/17/2017 7:40 PM, Abbott Liu wrote:
>On Wed, Oct 11, 2017 at 03:10:56PM -0700, Laura Abbott wrote:
>The decompressor does not link with the standard C library, so it
>needs to provide implementations of standard C library functionality
>where required.  That means, if we have any memset() users, we need
>to provide the memset() function.
>
>The undef is there to avoid the optimisation we have in asm/string.h
>for __memzero, because we don't want to use __memzero in the
>decompressor.
>
>Whether memset() is required depends on which compression method is
>being used - LZO and LZ4 appear to make direct references to it, but
>the inflate (gzip) decompressor code does not.
>
>What this means is that all supported kernel compression options need
>to be tested.

Thanks for your review. I am sorry that I am so late to reply your email.
I will test all arm kernel compression options.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
