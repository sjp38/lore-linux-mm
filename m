Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10A606B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:04:05 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id b7so2458669vkh.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:04:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c187si2787640vke.10.2017.10.18.10.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:04:04 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
Date: Wed, 18 Oct 2017 13:03:10 -0400
MIME-Version: 1.0
In-Reply-To: <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Andrey,

I asked Will, about it, and he preferred to have this patched added to 
the end of my series instead of replacing "arm64/kasan: add and use 
kasan_map_populate()".

In addition, Will's patch stops using large pages for kasan memory, and 
thus might add some regression in which case it is easier to revert just 
that patch instead of the whole series. It is unlikely that regression 
is going to be detectable, because kasan by itself makes system quiet 
slow already.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
