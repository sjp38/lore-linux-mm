Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DF42C6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 09:38:02 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so22079525pac.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 06:38:02 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id rv7si2987460pbb.128.2015.04.10.06.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 10 Apr 2015 06:38:02 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NML00HUFFDTLZ90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Apr 2015 14:41:53 +0100 (BST)
Message-id: <5527D22E.9090000@samsung.com>
Date: Fri, 10 Apr 2015 16:37:50 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
 <3164609.kEhR8riVSV@wuerfel> <5527AA94.5080803@samsung.com>
 <8790947.ikOtIjWHkt@wuerfel>
In-reply-to: <8790947.ikOtIjWHkt@wuerfel>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 04/10/2015 04:02 PM, Arnd Bergmann wrote:
> On Friday 10 April 2015 13:48:52 Andrey Ryabinin wrote:
>> On 04/09/2015 11:17 PM, Arnd Bergmann wrote:
>>> On Tuesday 24 March 2015 17:49:04 Andrey Ryabinin wrote:
>>>>  arch/arm64/mm/kasan_init.c           | 211 +++++++++++++++++++++++++++++++++++
>>>>
>>>
>>> Just one very high-level question: as this code is clearly derived from
>>> the x86 version and nontrivial, could we move most of it out of
>>> arch/{x86,arm64} into mm/kasan/init.c and have the rest in some header
>>> file?
>>>
>>
>> I think most of this could be moved out from arch code, but not everything.
>> E.g. kasan_init() function is too arch-specific.
> 
> Right, makes sense. So presumably, populate_zero_shadow could become a global
> function by another name, and possibly also handle registering the die
> handler, so you can call it from an architecture specific kasan_init() 
> function, right?
> 

Yep, you are right.

> 	Arnd
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
