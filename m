Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D86226B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 04:51:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44so4478087wry.5
        for <linux-mm@kvack.org>; Thu, 11 May 2017 01:51:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12si7059327wmi.75.2017.05.11.01.51.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 01:51:22 -0700 (PDT)
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
References: <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop> <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <32ac1107-14a3-fdff-ad48-0e246fec704f@suse.cz>
 <20170502130326.GJ14593@dhcp22.suse.cz>
 <398b341c-5fa7-1ad7-0840-752fa1908921@suse.cz>
 <20170504124648.GG31540@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <203a7f52-d444-dbcc-0cc0-0c77dffbcadd@suse.cz>
Date: Thu, 11 May 2017 10:51:17 +0200
MIME-Version: 1.0
In-Reply-To: <20170504124648.GG31540@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 05/04/2017 02:46 PM, Michal Hocko wrote:
> On Thu 04-05-17 14:33:24, Vlastimil Babka wrote:
>>>
>>> I am pretty sure s390 and ppc support NUMA and aim at supporting really
>>> large systems. 
>>
>> I don't see ppc there,
> 
> config KVM_BOOK3S_64_HV
>         tristate "KVM for POWER7 and later using hypervisor mode in host"
>         depends on KVM_BOOK3S_64 && PPC_POWERNV
>         select KVM_BOOK3S_HV_POSSIBLE
>         select MMU_NOTIFIER
>         select CMA
> 
> fa61a4e376d21 tries to explain some more

Uh, that's unfortunate then.

> [...]
>>> Are we really ready to add another thing like that? How are distribution
>>> kernels going to handle that?
>>
>> I still hope that generic enterprise/desktop distributions can disable
>> it, and it's only used for small devices with custom kernels.
>>
>> The config burden is already there in any case, it just translates to
>> extra migratetype and fastpath hooks, not extra zone and potentially
>> less nodes.
> 
> AFAIU the extra migrate type costs nothing when there are no cma
> reservations. And those hooks can be made noop behind static branch
> as well. So distribution kernels do not really have to be afraid of
> enabling CMA currently.

The tradeoff is unfortunate :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
