Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 563406B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:00:16 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s62so2233171vke.4
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:00:16 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t9si1041229uah.133.2018.03.14.08.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 08:00:15 -0700 (PDT)
Subject: Re: [PATCH 10/16] mm: remove obsolete alloc_remap()
References: <20180314143529.1456168-1-arnd@arndb.de>
 <20180314143958.1548568-1-arnd@arndb.de>
 <83b23320-e9de-a0cf-144c-1b60b9b7002a@oracle.com>
 <CAK8P3a1otS+2Q7qr0PE_VPXRp44kJqdZMhDFWuYK2g2jkNCCsA@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <0cd8068e-1e57-e1a8-474e-f1ea9a179ac2@oracle.com>
Date: Wed, 14 Mar 2018 10:59:57 -0400
MIME-Version: 1.0
In-Reply-To: <CAK8P3a1otS+2Q7qr0PE_VPXRp44kJqdZMhDFWuYK2g2jkNCCsA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Petr Tesarik <ptesarik@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Wei Yang <richard.weiyang@gmail.com>, Linux-MM <linux-mm@kvack.org>



On 03/14/2018 10:56 AM, Arnd Bergmann wrote:
> On Wed, Mar 14, 2018 at 3:50 PM, Pavel Tatashin
> <pasha.tatashin@oracle.com> wrote:
>> Hi Arnd,
>>
>> I like this cleanup, but arch/tile (which is afaik Orphaned but still in the gate) has:
>>
>> HAVE_ARCH_ALLOC_REMAP set to yes:
>>
>> arch/tile/Kconfig
>>  config HAVE_ARCH_ALLOC_REMAP
>>          def_bool y
> 
> It was a bit tricky to juggle the Cc lists here, but tile is removed
> in patch 06/10
> now. As I explained in the cover letter, it was originally planned to be marked
> deprecated for a while first, but after some more discussion, nobody could come
> up with a reason to keep it any longer. Same thing for mn10300,
> blackfin and cris.
> 

I see, thank you:

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
