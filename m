Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 112076B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 01:57:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 11:23:00 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E1B191258051
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:26:44 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S5vvLg31785058
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:27:57 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S5vdAv010178
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 15:57:39 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm/cma: Move dma contiguous changes into a seperate config
In-Reply-To: <51CC2530.2060605@samsung.com>
References: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51CC2530.2060605@samsung.com>
Date: Fri, 28 Jun 2013 11:27:38 +0530
Message-ID: <87li5u93ql.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, Michal Nazarewicz <mina86@mina86.com>

Marek Szyprowski <m.szyprowski@samsung.com> writes:

> Hello,
>
> On 6/24/2013 10:25 AM, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>
>> We want to use CMA for allocating hash page table and real mode area for
>> PPC64. Hence move DMA contiguous related changes into a seperate config
>> so that ppc64 can enable CMA without requiring DMA contiguous.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> It's nice to see that CMA is gaining another client in mainline Linux 
> kernel.
> I also like the idea of adding CONFIG_DMA_CMA for DMA-mapping related CMA
> use to let others to use alloc_contig_range() interface.
>
> However I noticed that You have almost copied the whole drivers/base.c for
> separate use with PPC64 KVM. Is this really necessary? I think it should be
> possible to isolate some common code, which plays with contiguous region
> management and use it for both alloc_contig_range() clients (dma-mapping and
> ppc64 kvm).
>

One of the reason for having book3s_hv_cma.c is that few specifics vary
between dma contiguous. We have different alignment needs. Also i will be
switching the allocation to 256K chunks, not page size, in the next
update. It is also not large code duplication. I will post V2 soon and
may be we can see if it is worth consolidating.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
