Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD7E6B0274
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:38:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so3407012oib.4
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 00:38:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor4293292oti.319.2017.10.12.00.38.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 00:38:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011082227.20546-1-liuwenliang@huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 12 Oct 2017 09:38:47 +0200
Message-ID: <CAK8P3a3OOMxsr0QM+Uukec4Uq4UxHnUYF6jozxbzwJisd7vOaA@mail.gmail.com>
Subject: Re: [PATCH 00/11] KASan for arm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, afzal.mohd.ma@gmail.com, Florian Fainelli <f.fainelli@gmail.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Christoffer Dall <cdall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, mawilcox@microsoft.com, Thomas Gleixner <tglx@linutronix.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Vladimir Murzin <vladimir.murzin@arm.com>, tixy@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Ingo Molnar <mingo@kernel.org>, grygorii.strashko@linaro.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Doug Berger <opendmb@gmail.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 10:22 AM, Abbott Liu <liuwenliang@huawei.com> wrote:
> Hi,all:
>    These patches add arch specific code for kernel address sanitizer
> (see Documentation/kasan.txt).

Nice!

When I build-tested KASAN on x86 and arm64, I ran into a lot of build-time
regressions (mostly warnings but also some errors), so I'd like to give it
a spin in my randconfig tree before this gets merged. Can you point me
to a git URL that I can pull into my testing tree?

I could of course apply the patches from email, but I expect that there
will be updated versions of the series, so it's easier if I can just pull
the latest version.

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
