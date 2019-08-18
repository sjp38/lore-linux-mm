Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 337A5C3A59B
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 03:25:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D649B20B7C
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 03:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="dY9He6fm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D649B20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DC946B0005; Sat, 17 Aug 2019 23:25:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 565016B0006; Sat, 17 Aug 2019 23:25:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42CCD6B000C; Sat, 17 Aug 2019 23:25:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE3D6B0005
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 23:25:33 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C6D1EA2D4
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 03:25:32 +0000 (UTC)
X-FDA: 75834108504.10.cough42_6a91044ba032b
X-HE-Tag: cough42_6a91044ba032b
X-Filterd-Recvd-Size: 9006
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 03:25:32 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id q4so10559162qtp.1
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 20:25:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=r3b3h8odkiIqkmQj2ElqAUg66aCs14UyDf1MJRMWwp8=;
        b=dY9He6fmctVtWY64cTT1RY/Z3qp0ZFJntzWCqjuhgq8Fp3NMhZ7xlPF6Kijr0mjdEa
         PR/dMG6iicUMKxO6E0Ha4pAS4l6LXYoxwxiUBgmbD2pmTUQwUzxpEUQbifIva2SCS2M2
         ztkxNWxiizUmT8WPEpNOzQAHShq8ZpXqcfOzFHfprkB9lwspeMps1mMre4IcuMAxeLyD
         efo6YuA4FHyPqZGQsq4dk3CIPau8b7JlYKJwIJXw3XsOt/di/C/2COkYtYxc/vEJtLJi
         rb66ynHcmrpe0Q9sug8IYgg3Rtloid65FEdEAZ4jQAwoC+PseKGkPUrvWkMPCPllznkg
         ncXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=r3b3h8odkiIqkmQj2ElqAUg66aCs14UyDf1MJRMWwp8=;
        b=DzQNYzBSaMXGZQT4fmpaaYny396IintTbsJSmcbbTCYVNf3TNJSCJmMqdwD30x4o3q
         q/3kUsRj8ycrWqTqBqlDmyl7P4BZXdgEuMP6YS3QjaJZhwH38TQHPJkjSiy92EpSADdy
         UwXVyG3Uzsxtw5asABlBTM80rug/Q2NZaB76hhZ1PekI0WgIU/enbr6GS+547r3bDXmW
         lNvIuHuoxOIl3LokYckRXQdtWRw7OubXwFsc0bUZI1PYzmYrqykJYT7gk8u0j9s11soW
         AjypcnOD8xbjbIt2HWMNUSw8FZGI4UL6w9gmQmKrlU0Qd9OTpvmrxMwFxEiUErm2INs1
         yevA==
X-Gm-Message-State: APjAAAWnIlY0tTsURKITI8iTuyTLxSZJ0qX3SAZ6Alw8YNf9OMcmaVbu
	k3jn1EYCFwYbvyHLfnf/6xlatg==
X-Google-Smtp-Source: APXvYqyAGvZQ2KIYulQCr8XmqdCw3d99xwkzFzAflWlDRBLNgjIOX2QVBp2vn4E4vyZEYE6O0f7q8Q==
X-Received: by 2002:ac8:289b:: with SMTP id i27mr15581485qti.67.1566098731470;
        Sat, 17 Aug 2019 20:25:31 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id f20sm7094444qtf.68.2019.08.17.20.25.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Aug 2019 20:25:30 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAPcyv4gofF-Xf0KTLH4EUkxuXdRO3ha-w+GoxgmiW7gOdS2nXQ@mail.gmail.com>
Date: Sat, 17 Aug 2019 23:25:28 -0400
Cc: Linux MM <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 kasan-dev@googlegroups.com,
 Baoquan He <bhe@redhat.com>,
 Dave Jiang <dave.jiang@intel.com>,
 Thomas Gleixner <tglx@linutronix.de>
Content-Transfer-Encoding: quoted-printable
Message-Id: <0AC959D7-5BCB-4A81-BBDC-990E9826EB45@lca.pw>
References: <1565991345.8572.28.camel@lca.pw>
 <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
 <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw>
 <CAPcyv4h9Y7wSdF+jnNzLDRobnjzLfkGLpJsML2XYLUZZZUPsQA@mail.gmail.com>
 <E7A04694-504D-4FB3-9864-03C2CBA3898E@lca.pw>
 <CAPcyv4gofF-Xf0KTLH4EUkxuXdRO3ha-w+GoxgmiW7gOdS2nXQ@mail.gmail.com>
To: Dan Williams <dan.j.williams@intel.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 17, 2019, at 12:59 PM, Dan Williams <dan.j.williams@intel.com> =
wrote:
>=20
> On Sat, Aug 17, 2019 at 4:13 AM Qian Cai <cai@lca.pw> wrote:
>>=20
>>=20
>>=20
>>> On Aug 16, 2019, at 11:57 PM, Dan Williams =
<dan.j.williams@intel.com> wrote:
>>>=20
>>> On Fri, Aug 16, 2019 at 8:34 PM Qian Cai <cai@lca.pw> wrote:
>>>>=20
>>>>=20
>>>>=20
>>>>> On Aug 16, 2019, at 5:48 PM, Dan Williams =
<dan.j.williams@intel.com> wrote:
>>>>>=20
>>>>> On Fri, Aug 16, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
>>>>>>=20
>>>>>> Every so often recently, booting Intel CPU server on linux-next =
triggers this
>>>>>> warning. Trying to figure out if  the commit 7cc7867fb061
>>>>>> ("mm/devm_memremap_pages: enable sub-section remap") is the =
culprit here.
>>>>>>=20
>>>>>> # ./scripts/faddr2line vmlinux devm_memremap_pages+0x894/0xc70
>>>>>> devm_memremap_pages+0x894/0xc70:
>>>>>> devm_memremap_pages at mm/memremap.c:307
>>>>>=20
>>>>> Previously the forced section alignment in devm_memremap_pages() =
would
>>>>> cause the implementation to never violate the =
KASAN_SHADOW_SCALE_SIZE
>>>>> (12K on x86) constraint.
>>>>>=20
>>>>> Can you provide a dump of /proc/iomem? I'm curious what resource =
is
>>>>> triggering such a small alignment granularity.
>>>>=20
>>>> This is with memmap=3D4G!4G ,
>>>>=20
>>>> # cat /proc/iomem
>>> [..]
>>>> 100000000-155dfffff : Persistent Memory (legacy)
>>>> 100000000-155dfffff : namespace0.0
>>>> 155e00000-15982bfff : System RAM
>>>> 155e00000-156a00fa0 : Kernel code
>>>> 156a00fa1-15765d67f : Kernel data
>>>> 157837000-1597fffff : Kernel bss
>>>> 15982c000-1ffffffff : Persistent Memory (legacy)
>>>> 200000000-87fffffff : System RAM
>>>=20
>>> Ok, looks like 4G is bad choice to land the pmem emulation on this
>>> system because it collides with where the kernel is deployed and =
gets
>>> broken into tiny pieces that violate kasan's. This is a known =
problem
>>> with memmap=3D. You need to pick an memory range that does not =
collide
>>> with anything else. See:
>>>=20
>>>   =
https://nvdimm.wiki.kernel.org/how_to_choose_the_correct_memmap_kernel_par=
ameter_for_pmem_on_your_system
>>>=20
>>> ...for more info.
>>=20
>> Well, it seems I did exactly follow the information in that link,
>>=20
>> [    0.000000] BIOS-provided physical RAM map:
>> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093fff] =
usable
>> [    0.000000] BIOS-e820: [mem 0x0000000000094000-0x000000000009ffff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000005a7a0fff] =
usable
>> [    0.000000] BIOS-e820: [mem 0x000000005a7a1000-0x000000005b5e0fff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x000000005b5e1000-0x00000000790fefff] =
usable
>> [    0.000000] BIOS-e820: [mem 0x00000000790ff000-0x00000000791fefff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x00000000791ff000-0x000000007b5fefff] =
ACPI NVS
>> [    0.000000] BIOS-e820: [mem 0x000000007b5ff000-0x000000007b7fefff] =
ACPI data
>> [    0.000000] BIOS-e820: [mem 0x000000007b7ff000-0x000000007b7fffff] =
usable
>> [    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] =
reserved
>> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000087fffffff] =
usable
>>=20
>> Where 4G is good. Then,
>>=20
>> [    0.000000] user-defined physical RAM map:
>> [    0.000000] user: [mem 0x0000000000000000-0x0000000000093fff] =
usable
>> [    0.000000] user: [mem 0x0000000000094000-0x000000000009ffff] =
reserved
>> [    0.000000] user: [mem 0x00000000000e0000-0x00000000000fffff] =
reserved
>> [    0.000000] user: [mem 0x0000000000100000-0x000000005a7a0fff] =
usable
>> [    0.000000] user: [mem 0x000000005a7a1000-0x000000005b5e0fff] =
reserved
>> [    0.000000] user: [mem 0x000000005b5e1000-0x00000000790fefff] =
usable
>> [    0.000000] user: [mem 0x00000000790ff000-0x00000000791fefff] =
reserved
>> [    0.000000] user: [mem 0x00000000791ff000-0x000000007b5fefff] ACPI =
NVS
>> [    0.000000] user: [mem 0x000000007b5ff000-0x000000007b7fefff] ACPI =
data
>> [    0.000000] user: [mem 0x000000007b7ff000-0x000000007b7fffff] =
usable
>> [    0.000000] user: [mem 0x000000007b800000-0x000000008fffffff] =
reserved
>> [    0.000000] user: [mem 0x00000000ff800000-0x00000000ffffffff] =
reserved
>> [    0.000000] user: [mem 0x0000000100000000-0x00000001ffffffff] =
persistent (type 12)
>> [    0.000000] user: [mem 0x0000000200000000-0x000000087fffffff] =
usable
>>=20
>> The doc did mention that =E2=80=9CThere seems to be an issue with =
CONFIG_KSAN at the moment however.=E2=80=9D
>> without more detail though.
>=20
> Does disabling CONFIG_RANDOMIZE_BASE help? Maybe that workaround has
> regressed. Effectively we need to find what is causing the kernel to
> sometimes be placed in the middle of a custom reserved memmap=3D =
range.

Yes, disabling KASLR works good so far. Assuming the workaround, i.e., =
f28442497b5c
(=E2=80=9Cx86/boot: Fix KASLR and memmap=3D collision=E2=80=9D) is =
correct.

The only other commit that might regress it from my research so far is,

d52e7d5a952c ("x86/KASLR: Parse all 'memmap=3D' boot option entries=E2=80=9D=
)



