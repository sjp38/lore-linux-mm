Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE536B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:16:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 37so6658821qto.2
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:16:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s68sor1710701qkc.37.2017.10.11.12.16.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:16:55 -0700 (PDT)
Subject: Re: [PATCH 05/11] Disable kasan's instrumentation
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-6-liuwenliang@huawei.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <cf3776c0-b6e0-7a6e-9d43-d77ddd83749b@gmail.com>
Date: Wed, 11 Oct 2017 12:16:50 -0700
MIME-Version: 1.0
In-Reply-To: <20171011082227.20546-6-liuwenliang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On 10/11/2017 01:22 AM, Abbott Liu wrote:
> From: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
>  To avoid some build and runtime errors, compiler's instrumentation must
>  be disabled for code not linked with kernel image.
> 
> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> Signed-off-by: Abbott Liu <liuwenliang@huawei.com>

Same as patch 3, this needs to be moved before you allow KAsan to be
enabled/selected. This has little to no dependencies on other patches so
this could be moved as the first patch in the series.

Thanks!
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
