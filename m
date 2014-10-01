Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 408646B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 10:18:48 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so330163pdj.4
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 07:18:47 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id dk4si1008780pbc.108.2014.10.01.07.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 01 Oct 2014 07:18:47 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NCR00EKMRVVTM40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 01 Oct 2014 15:21:32 +0100 (BST)
Message-id: <542C0BA3.7000504@samsung.com>
Date: Wed, 01 Oct 2014 18:11:47 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 11/13] kmemleak: disable kasan instrumentation for
 kmemleak
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-12-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+aJ9htaruQ1Nn7+MSGwtNzRb_hfytQo98J1wq5N6oh1BA@mail.gmail.com>
 <CAPAsAGxLxCxOayqcu=PbgFG6J7JEuL8J3+ouz94p_k0v0Hy=wA@mail.gmail.com>
 <CACT4Y+Z4N5hpz_ZXFOCCbv7sbz2kzrF6gYHMbasDFNwpdOK30Q@mail.gmail.com>
 <20141001103930.GG20364@e104818-lin.cambridge.arm.com>
 <542BE977.3040807@samsung.com>
 <CACT4Y+ZXcZ=BLGjXamfpV+5R-5pahKGTeMcRoLkcxY7PQGatjw@mail.gmail.com>
In-reply-to: 
 <CACT4Y+ZXcZ=BLGjXamfpV+5R-5pahKGTeMcRoLkcxY7PQGatjw@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/01/2014 05:27 PM, Dmitry Vyukov wrote:
> On Wed, Oct 1, 2014 at 3:45 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> On 10/01/2014 02:39 PM, Catalin Marinas wrote:
>>> On Mon, Sep 29, 2014 at 03:10:01PM +0100, Dmitry Vyukov wrote:
>>>> On Fri, Sep 26, 2014 at 9:36 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>>>>> 2014-09-26 21:10 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
>>>>>> Looks good to me.
>>>>>>
>>>>>> We can disable kasan instrumentation of this file as well.
>>>>>
>>>>> Yes, but why? I don't think we need that.
>>>>
>>>> Just gut feeling. Such tools usually don't play well together. For
>>>> example, due to asan quarantine lots of leaks will be missed (if we
>>>> pretend that tools work together, end users will use them together and
>>>> miss bugs). I won't be surprised if leak detector touches freed
>>>> objects under some circumstances as well.
>>>> We can do this if/when discover actual compatibility issues, of course.
>>>
>>> I think it's worth testing them together first.
>>>
>>
>> I did test them together. With this patch applied both tools works without problems.
> 
> What do you mean "works without problems"? Are you sure that kmemleak
> still detects all leaks it is intended to detect?
> 

Yes I'm sure about that. And how kasan could affect on kmemleak's capability to detect leaks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
