Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8596B0260
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:15:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p9so4540988pgc.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:15:16 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0123.outbound.protection.outlook.com. [104.47.0.123])
        by mx.google.com with ESMTPS id 17si3462157pfk.175.2017.10.18.10.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 10:15:15 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
 <20171018170651.GG21820@arm.com>
 <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f1cb8d18-4d0f-1f88-c3c5-0add8c6c077a@virtuozzo.com>
Date: Wed, 18 Oct 2017 20:18:12 +0300
MIME-Version: 1.0
In-Reply-To: <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/18/2017 08:08 PM, Pavel Tatashin wrote:
>>
>> As I said, I'm fine either way, I just didn't want to cause extra work
>> or rebasing:
>>
>> http://lists.infradead.org/pipermail/linux-arm-kernel/2017-October/535703.html
> 
> Makes sense. I am also fine either way, I can submit a new patch merging together the two if needed.
> 

Please, do this. Single patch makes more sense


> Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
