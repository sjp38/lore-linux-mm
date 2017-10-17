Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC1A66B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:42:12 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k40so454896lfi.5
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:42:12 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id j19si3099866lfg.676.2017.10.17.06.42.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 06:42:11 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Tue, 17 Oct 2017 13:28:25 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CB25@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <b53b3281-5eef-7cbd-c7d3-5417d764667b@gmail.com>
 <20171011214131.GV20805@n2100.armlinux.org.uk>
In-Reply-To: <20171011214131.GV20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Florian Fainelli <f.fainelli@gmail.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Zengweilin <zengweilin@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dailei <dylix.dailei@huawei.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, Jiazhenghua <jiazhenghua@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Heshaoliang <heshaoliang@huawei.com>

2017.10.12  05:42 AM  Russell King - ARM Linux [mailto:linux@armlinux.org.u=
k] wrote:

>> Please don't make this "exclusive" just conditionally call=20
>> kasan_early_init(), remove the call to start_kernel from=20
>> kasan_early_init and keep the call to start_kernel here.
>iow:
>
>#ifdef CONFIG_KASAN
>	bl	kasan_early_init
>#endif
>	b	start_kernel
>
>This has the advantage that we don't leave any stack frame from
>kasan_early_init() on the init task stack.

Thanks for your review.  I tested your opinion and it work well.
I agree with you that it is better to use follow code
#ifdef CONFIG_KASAN
	bl	kasan_early_init
#endif
	b	start_kernel

than :
#ifdef CONFIG_KASAN
	bl	kasan_early_init
#else
	b	start_kernel
#endif




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
