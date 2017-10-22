Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id B75F66B0069
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 08:34:48 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id z195so18094532ywz.14
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 05:34:48 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id z189si589314ybz.146.2017.10.22.05.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Oct 2017 05:34:47 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 03/11] arm: Kconfig: enable KASan
Date: Sun, 22 Oct 2017 12:27:57 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CEF0@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-4-liuwenliang@huawei.com>
 <a3902e32-0141-9616-ba3e-9cbbd396b99a@gmail.com>
 <20171019123453.GV20805@n2100.armlinux.org.uk>
In-Reply-To: <20171019123453.GV20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Florian Fainelli <f.fainelli@gmail.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Zengweilin <zengweilin@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dailei <dylix.dailei@huawei.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, Jiazhenghua <jiazhenghua@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Heshaoliang <heshaoliang@huawei.com>

On 10/22/2017 01:22 AM, Russell King - ARM Linux wrote:
>On Wed, Oct 11, 2017 at 12:15:44PM -0700, Florian Fainelli wrote:
>> On 10/11/2017 01:22 AM, Abbott Liu wrote:
>> > From: Andrey Ryabinin <a.ryabinin@samsung.com>
>> >=20
>> > This patch enable kernel address sanitizer for arm.
>> >=20
>> > Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
>> > Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
>>=20
>> This needs to be the last patch in the series, otherwise you allow
>> people between patch 3 and 11 to have varying degrees of experience with
>> this patch series depending on their system type (LPAE or not, etc.)
>
>As the series stands, if patches 1-3 are applied, and KASAN is enabled,
>there are various constants that end up being undefined, and the kernel
>build will fail.  That is, of course, not acceptable.
>
>KASAN must not be available until support for it is functionally
>complete.

Thanks for Florian Fainelli and Russell King's review.
I'm going to change it in the new version.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
