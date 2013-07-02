Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DC8A96B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 11:31:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 20:56:36 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id ADB7F1258052
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 21:00:56 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r62FW7k59764914
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 21:02:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r62FVcVn016356
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 01:31:39 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 2/4] powerpc/kvm: Contiguous memory allocator based hash page table allocation
In-Reply-To: <51D2EDD7.9060205@suse.de>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D2EDD7.9060205@suse.de>
Date: Tue, 02 Jul 2013 21:01:37 +0530
Message-ID: <87wqp9yo4m.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: benh@kernel.crashing.org, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

Alexander Graf <agraf@suse.de> writes:

> On 07/02/2013 07:45 AM, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>
>> Powerpc architecture uses a hash based page table mechanism for mapping virtual
>> addresses to physical address. The architecture require this hash page table to
>> be physically contiguous. With KVM on Powerpc currently we use early reservation
>> mechanism for allocating guest hash page table. This implies that we need to
>> reserve a big memory region to ensure we can create large number of guest
>> simultaneously with KVM on Power. Another disadvantage is that the reserved memory
>> is not available to rest of the subsystems and and that implies we limit the total
>> available memory in the host.
>>
>> This patch series switch the guest hash page table allocation to use
>> contiguous memory allocator.
>>
>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>
> Is CMA a mandatory option in the kernel? Or can it be optionally 
> disabled? If it can be disabled, we should keep the preallocated 
> fallback case around for systems that have CMA disabled.
>

CMA is not a mandatory option. But we have 

config KVM_BOOK3S_64_HV
	bool "KVM support for POWER7 and PPC970 using hypervisor mode in host"
	depends on KVM_BOOK3S_64
	select MMU_NOTIFIER
	select CMA

ie, for book3s HV we select CMA and only this CMA needs is memblock
which we already support

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
