Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 363C96B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:15:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h4so6660332qtk.4
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:15:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor10043320qtk.16.2017.10.11.12.15.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:15:50 -0700 (PDT)
Subject: Re: [PATCH 03/11] arm: Kconfig: enable KASan
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-4-liuwenliang@huawei.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <a3902e32-0141-9616-ba3e-9cbbd396b99a@gmail.com>
Date: Wed, 11 Oct 2017 12:15:44 -0700
MIME-Version: 1.0
In-Reply-To: <20171011082227.20546-4-liuwenliang@huawei.com>
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
> This patch enable kernel address sanitizer for arm.
> 
> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> Signed-off-by: Abbott Liu <liuwenliang@huawei.com>

This needs to be the last patch in the series, otherwise you allow
people between patch 3 and 11 to have varying degrees of experience with
this patch series depending on their system type (LPAE or not, etc.)
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
