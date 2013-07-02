Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 693B56B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 11:34:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 12:30:09 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 42F303578051
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 01:34:08 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r62FXxra23789672
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 01:33:59 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r62FY7bd003290
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 01:34:07 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 1/4] mm/cma: Move dma contiguous changes into a seperate config
In-Reply-To: <51D28D51.6090305@samsung.com>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D28D51.6090305@samsung.com>
Date: Tue, 02 Jul 2013 21:03:57 +0530
Message-ID: <87txkdyo0q.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, agraf@suse.de, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

Marek Szyprowski <m.szyprowski@samsung.com> writes:

> Hello,
>
> On 7/2/2013 7:45 AM, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>
>> We want to use CMA for allocating hash page table and real mode area for
>> PPC64. Hence move DMA contiguous related changes into a seperate config
>> so that ppc64 can enable CMA without requiring DMA contiguous.
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> Acked-by: Paul Mackerras <paulus@samba.org>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> OK. It looks that there is not that much that can be easily shared between
> dma-mapping cma provider and ppc/kvm cma allocator. I would prefer to merge
> patch 1/4 to my dma-mapping tree, because I plan some significant changes in
> cma code, see: 
> http://thread.gmane.org/gmane.linux.drivers.devicetree/40013/
> I think it is better to keep those changes together.
>
> For now I've merged your patch with removed defconfig updates. AFAIK such
> changes require separate handling to avoid pointless merge conflicts.

How do we get the defconfig changes done ?

> I've
> also prepared a topic branch for-v3.12-cma-dma, available at
> git://git.linaro.org/people/mszyprowski/linux-dma-mapping, which You can 
> merge
> together with your changes to ppc kernel trees.
>

Thanks. Will update accordingly as other patches get picked into
respective trees

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
