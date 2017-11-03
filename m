Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9B1E6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:52:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b9so536940wmh.5
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:52:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g32si5732942edd.421.2017.11.03.08.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 08:51:59 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
 <20171018170651.GG21820@arm.com>
 <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
 <f1cb8d18-4d0f-1f88-c3c5-0add8c6c077a@virtuozzo.com>
 <a587687a-5d90-c03d-f3d2-1ea9cab1b0c4@oracle.com>
 <07ab0b77-0e2a-97b5-73ff-a6598bcb94cd@virtuozzo.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <7f4e35ba-2448-16ba-63e1-229eb30b068b@oracle.com>
Date: Fri, 3 Nov 2017 11:50:53 -0400
MIME-Version: 1.0
In-Reply-To: <07ab0b77-0e2a-97b5-73ff-a6598bcb94cd@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

>> 1. Replace these two patches:
>>
>> arm64/kasan: add and use kasan_map_populate()
>> x86/kasan: add and use kasan_map_populate()
>>
>> With:
>>
>> x86/mm/kasan: don't use vmemmap_populate() to initialize
>>  A shadow
>> arm64/mm/kasan: don't use vmemmap_populate() to initialize
>>  A shadow
>>
> 
> Pavel, could you please send the patches? These patches doesn't interfere with rest of the series,
> so I think it should be enough to send just two patches to replace the old ones.
> 

Hi Andrey,

I asked Michal and Andrew how to proceed but never received a reply from 
them. The patches independent from the deferred page init series as long 
as they come before the series.

Anyway, I will post these two patches to the mailing list soon. But, not 
really sure if they will be taken into mm-tree.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
