Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1629A6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:24:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d9so6481092qtd.8
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:24:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d79si7278431qkc.32.2017.10.18.10.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:24:03 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
 <20171018170651.GG21820@arm.com>
 <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
 <f1cb8d18-4d0f-1f88-c3c5-0add8c6c077a@virtuozzo.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a587687a-5d90-c03d-f3d2-1ea9cab1b0c4@oracle.com>
Date: Wed, 18 Oct 2017 13:23:22 -0400
MIME-Version: 1.0
In-Reply-To: <f1cb8d18-4d0f-1f88-c3c5-0add8c6c077a@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Andrew and Michal,

There are a few changes I need to do to my series:

1. Replace these two patches:

arm64/kasan: add and use kasan_map_populate()
x86/kasan: add and use kasan_map_populate()

With:

x86/mm/kasan: don't use vmemmap_populate() to initialize
  shadow
arm64/mm/kasan: don't use vmemmap_populate() to initialize
  shadow

2. Fix a kbuild warning about section mismatch in
mm: deferred_init_memmap improvements

How should I proceed to get these replaced in mm-tree? Send three new 
patches, or send a new series?

Thank you,
Pavel

On 10/18/2017 01:18 PM, Andrey Ryabinin wrote:
> On 10/18/2017 08:08 PM, Pavel Tatashin wrote:
>>>
>>> As I said, I'm fine either way, I just didn't want to cause extra work
>>> or rebasing:
>>>
>>> http://lists.infradead.org/pipermail/linux-arm-kernel/2017-October/535703.html
>>
>> Makes sense. I am also fine either way, I can submit a new patch merging together the two if needed.
>>
> 
> Please, do this. Single patch makes more sense
> 
> 
>> Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
