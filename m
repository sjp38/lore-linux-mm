Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1584C6B0007
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 21:20:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e185so1031119wmg.5
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 18:20:44 -0700 (PDT)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id u38si9816372wrc.106.2018.03.18.18.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 18:20:42 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH v2 0/7] KASan for arm
Date: Mon, 19 Mar 2018 01:20:35 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0076FBE@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/19/2018 03:14 AM, Florian Fainelli wrote:
>Thanks for posting these patches! Just FWIW, you cannot quite add
>someone's Tested-by for a patch series that was just resubmitted given
>the differences with v1. I just gave it a spin on a Cortex-A5 (no LPAE)
>and it looks like test_kasan.ko is passing, great job!

I'm sorry.
Thanks for your testing very much!
I forget to add Tested-by in cover letter patch file. But I have alreadly a=
dded
Tested-by in some of following patch.=20
In the next version I am going to add Tested-by in all patches.
