Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 692A86B002D
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 21:38:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z2-v6so3998085plk.3
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 18:38:14 -0700 (PDT)
Received: from huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id p68si9229181pga.462.2018.04.07.18.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 18:38:13 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH v3 2/6] Disable instrumentation for some code
Date: Sun, 8 Apr 2018 01:38:05 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0077F5D@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Marc Zyngier <marc.zyngier@arm.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "dvyukov@google.com" <dvyukov@google.com>, "corbet@lwn.net" <corbet@lwn.net>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "julien.thierry@arm.com" <julien.thierry@arm.com>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 03, 2018 at 19:39, Russell King - ARM Linux:
>On Tue, Apr 03, 2018 at 12:30:42PM +0100, Marc Zyngier wrote:
>> On 02/04/18 13:04, Abbott Liu wrote:
>> > From: Andrey Ryabinin <a.ryabinin@samsung.com>
>> >=20
>> > Disable instrumentation for arch/arm/boot/compressed/*
>> > ,arch/arm/kvm/hyp/* and arch/arm/vdso/* because those
>> > code won't linkd with kernel image.
>> >=20
>> > Disable kasan check in the function unwind_pop_register
>> > because it doesn't matter that kasan checks failed when
>> > unwind_pop_register read stack memory of task.
>> >=20
>> > Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
>> > Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>> > Reviewed-by: Marc Zyngier <marc.zyngier@arm.com>
>>=20
>> Just because I replied to this patch doesn't mean you can stick my
>> Reviewed-by tag on it. Please drop this tag until I explicitly say that
>> you can add it (see Documentation/process/submitting-patches.rst,
>> section 11).
>>=20
>> Same goes for patch 1.
>
>Same goes for that reviewed-by line for me.  From my records, I never
>even looked at patch 2 from the first posting, and I don't appear to
>have the second posting in my mailbox (it's probably been classed as
>spam by dspam.)  So these reviewed-by lines seem to be totally
>misleading.

Thank Marc Zyngier and Russell King.
I have read Documentation/process/submitting-patches.rst and understand
it now. I will change it in the next version.
