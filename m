Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D8F46B01C1
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 05:30:42 -0400 (EDT)
Received: by bwz18 with SMTP id 18so115870bwz.14
        for <linux-mm@kvack.org>; Fri, 11 Jun 2010 02:30:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <tnxaar2c4i7.fsf@e102109-lin.cambridge.arm.com>
References: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
	<1275929000.3021.56.camel@e102109-lin.cambridge.arm.com>
	<AANLkTilsCkBiGtfEKkNXYclsRKhfuq4yI_1mrxMa8yJG@mail.gmail.com>
	<AANLkTik-cwrabXH_bQRPFtTo3C9r30B83jMf4IwJKCms@mail.gmail.com>
	<20100609211617.3e7e41bd@annuminas.surriel.com>
	<AANLkTin9UTy3qSWJ8u3b1hwhnsX5NHCZNzkFbH9_-vIZ@mail.gmail.com>
	<1276168866.24535.25.camel@e102109-lin.cambridge.arm.com>
	<AANLkTikl2Lp6dhDIN2NpyZHJne_vhOYJrwwBGebkslCf@mail.gmail.com>
	<tnxaar2c4i7.fsf@e102109-lin.cambridge.arm.com>
Date: Fri, 11 Jun 2010 17:30:39 +0800
Message-ID: <AANLkTikWX23CTqSruw_UcnRYb2SymDTxm8F6Zu8FgjG8@mail.gmail.com>
Subject: Re: [PATCH -mm] only drop root anon_vma if not self
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 5:17 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> Dave Young <hidave.darkstar@gmail.com> wrote:
>> On Thu, Jun 10, 2010 at 7:21 PM, Catalin Marinas
>> <catalin.marinas@arm.com> wrote:
>>> On Thu, 2010-06-10 at 02:30 +0100, Dave Young wrote:
>>>> On Thu, Jun 10, 2010 at 9:16 AM, Rik van Riel <riel@redhat.com> wrote:
>>>> > On Wed, 9 Jun 2010 17:19:02 +0800
>>>> > Dave Young <hidave.darkstar@gmail.com> wrote:
>>>> >
>>>> >> > Manually bisected mm patches, the memleak caused by following patch:
>>>> >> >
>>>> >> > mm-extend-ksm-refcounts-to-the-anon_vma-root.patch
>>>> >>
>>>> >>
>>>> >> So I guess the refcount break, either drop-without-get or over-drop
>>>> >
>>>> > I'm guessing I did not run the kernel with enough debug options enabled
>>>> > when I tested my patches...
>>>> >
>>>> > Dave & Catalin, thank you for tracking this down.
>>>> >
>>>> > Dave, does the below patch fix your issue?
>>>>
>>>> Yes, it fixed the issue. Thanks.
>>>
>>> Thanks for investigating this issue.
>>>
>>> BTW, without my kmemleak nobootmem patch (and CONFIG_NOBOOTMEM enabled),
>>> do you get other leaks (false positives).
>>
>> I didn't see difference before/after apply your patch, how to test
>> specific to bootmem?
>
> With Rik's patch applied and CONFIG_NOBOOTMEM enabled, do you get any
> false postives if my kmemleak patch isn't applied?

No more, except a few acpi issue which always there

>
> Thanks.
>
> --
> Catalin
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
