Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01E4B6B0009
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 21:23:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a9so8604471oia.1
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 18:23:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m40sor5068882otb.156.2018.03.18.18.23.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Mar 2018 18:23:24 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] KASan for arm
References: <B8AC3E80E903784988AB3003E3E97330C0076FBE@dggemm510-mbs.china.huawei.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <b9a813b8-30fe-ef17-ff79-372c2134723f@gmail.com>
Date: Sun, 18 Mar 2018 18:23:15 -0700
MIME-Version: 1.0
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0076FBE@dggemm510-mbs.china.huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 03/18/2018 06:20 PM, Liuwenliang (Abbott Liu) wrote:
> On 03/19/2018 03:14 AM, Florian Fainelli wrote:
>> Thanks for posting these patches! Just FWIW, you cannot quite add
>> someone's Tested-by for a patch series that was just resubmitted given
>> the differences with v1. I just gave it a spin on a Cortex-A5 (no LPAE)
>> and it looks like test_kasan.ko is passing, great job!
> 
> I'm sorry.
> Thanks for your testing very much!
> I forget to add Tested-by in cover letter patch file. But I have alreadly added
> Tested-by in some of following patch. 
> In the next version I am going to add Tested-by in all patches.

This is not exactly what I meant. When you submit a v2 of your patches,
you must wait for people to give you their test results. The Tested-by
applied to v1, and so much has changed it is no longer valid for v2
unless someone tells you they tested v2. Hope this is clearer.
-- 
Florian
