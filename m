Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91B0C6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 20:09:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p7-v6so15903180wrj.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 17:09:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n93-v6sor8886200wrb.51.2018.05.22.17.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 17:09:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180522170257.ae5387d8717e81def908a53b@linux-foundation.org>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz> <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com> <20180517164947.GV12670@dhcp22.suse.cz>
 <20180517170816.GW12670@dhcp22.suse.cz> <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
 <20180518040104.GA17433@js1304-desktop> <20180519144632.GE23723@intel.com>
 <20180521061631.GA26882@js1304-desktop> <20180522170257.ae5387d8717e81def908a53b@linux-foundation.org>
From: Joonsoo Kim <js1304@gmail.com>
Date: Wed, 23 May 2018 09:09:04 +0900
Message-ID: <CAAmzW4N=r9CwU48Uha66DUH-7A80gjMXLEF7K4kAK=DaZY8nTw@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?VmlsbGUgU3lyasOkbMOk?= <ville.syrjala@linux.intel.com>, Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2018-05-23 9:02 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Mon, 21 May 2018 15:16:33 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
>
>> > (gdb) list *(dma_direct_alloc+0x22f)
>> > 0x573fbf is in dma_direct_alloc (../lib/dma-direct.c:104).
>> > 94
>> > 95          if (!page)
>> > 96                  return NULL;
>> > 97          ret = page_address(page);
>> > 98          if (force_dma_unencrypted()) {
>> > 99                  set_memory_decrypted((unsigned long)ret, 1 << page_order);
>> > 100                 *dma_handle = __phys_to_dma(dev, page_to_phys(page));
>> > 101         } else {
>> > 102                 *dma_handle = phys_to_dma(dev, page_to_phys(page));
>> > 103         }
>> > 104         memset(ret, 0, size);
>> > 105         return ret;
>> > 106 }
>> >
>>
>> Okay. I find the reason about this error.
>
> It's getting rather late and we don't seem to have a final set of fixes
> yet.  Perhaps the best approach here is to revert and try again for
> 4.18?

Yes. Reverting seems to be a right decision at this moment.
Could you apply original revert patch from Ville?

Thanks.
