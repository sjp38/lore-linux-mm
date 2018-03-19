Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A016C6B0007
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 21:02:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c16so7536815pgv.8
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 18:02:38 -0700 (PDT)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id t2si1823296pfd.233.2018.03.18.18.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 18:02:37 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 1/7] 2 1-byte checks more safer for memory_is_poisoned_16
Date: Mon, 19 Mar 2018 01:02:34 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0076F8D@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Mar 18, 2018 at 21:21:20PM +0800, Russell King wrote:
>On Sun, Mar 18, 2018 at 08:53:36PM +0800, Abbott Liu wrote:
>> Because in some architecture(eg. arm) instruction set, non-aligned
>> access support is not very well, so 2 1-byte checks is more
>> safer than 1 2-byte check. The impact on performance is small
>> because 16-byte accesses are not too common.
>
>This is unnecessary:
>
>1. a load of a 16-bit quantity will work as desired on modern ARMs.
>2. Networking already relies on unaligned loads to work as per x86
>   (iow, an unaligned 32-bit load loads the 32-bits at the address
>   even if it's not naturally aligned, and that also goes for 16-bit
>   accesses.)
>
>If these are rare (which you say above - "not too common") then it's
>much better to leave the code as-is, because it will most likely be
>faster on modern CPUs, and the impact for older generation CPUs is
>likely to be low.

Thanks for your review.
OK, I am going to remove this patch in the next version.
