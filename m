Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBB96B0005
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 21:56:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 17so8688246pfo.23
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 18:56:56 -0700 (PDT)
Received: from huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id y67si9782198pfd.195.2018.03.18.18.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 18:56:54 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH v2 0/7] KASan for arm
Date: Mon, 19 Mar 2018 01:56:52 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0076FFD@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/19/2018 09:23 AM, Florian Fainelli wrote:
>On 03/18/2018 06:20 PM, Liuwenliang (Abbott Liu) wrote:
>> On 03/19/2018 03:14 AM, Florian Fainelli wrote:
>>> Thanks for posting these patches! Just FWIW, you cannot quite add
>>> someone's Tested-by for a patch series that was just resubmitted given
>>> the differences with v1. I just gave it a spin on a Cortex-A5 (no LPAE)
>>> and it looks like test_kasan.ko is passing, great job!
>>=20
>> I'm sorry.
>> Thanks for your testing very much!
>> I forget to add Tested-by in cover letter patch file. But I have alreadl=
y added
>> Tested-by in some of following patch.=20
>> In the next version I am going to add Tested-by in all patches.
>
>This is not exactly what I meant. When you submit a v2 of your patches,
>you must wait for people to give you their test results. The Tested-by
>applied to v1, and so much has changed it is no longer valid for v2
>unless someone tells you they tested v2. Hope this is clearer.

Ok, I understand now. thank you for your explanation.
