Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 807646B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:37:44 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 189so9172723iow.8
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:37:44 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0122.outbound.protection.outlook.com. [104.47.1.122])
        by mx.google.com with ESMTPS id y81si2590140itb.68.2017.11.03.08.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 08:37:37 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
 <20171018170651.GG21820@arm.com>
 <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
 <f1cb8d18-4d0f-1f88-c3c5-0add8c6c077a@virtuozzo.com>
 <a587687a-5d90-c03d-f3d2-1ea9cab1b0c4@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <07ab0b77-0e2a-97b5-73ff-a6598bcb94cd@virtuozzo.com>
Date: Fri, 3 Nov 2017 18:40:47 +0300
MIME-Version: 1.0
In-Reply-To: <a587687a-5d90-c03d-f3d2-1ea9cab1b0c4@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com



On 10/18/2017 08:23 PM, Pavel Tatashin wrote:
> Hi Andrew and Michal,
> 
> There are a few changes I need to do to my series:
> 
> 1. Replace these two patches:
> 
> arm64/kasan: add and use kasan_map_populate()
> x86/kasan: add and use kasan_map_populate()
> 
> With:
> 
> x86/mm/kasan: don't use vmemmap_populate() to initialize
> A shadow
> arm64/mm/kasan: don't use vmemmap_populate() to initialize
> A shadow
> 

Pavel, could you please send the patches? These patches doesn't interfere with rest of the series,
so I think it should be enough to send just two patches to replace the old ones.




> 2. Fix a kbuild warning about section mismatch in
> mm: deferred_init_memmap improvements
> 
> How should I proceed to get these replaced in mm-tree? Send three new patches, or send a new series?
> 
> Thank you,
> Pavel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
