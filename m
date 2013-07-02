Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D2DAA6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 11:12:30 -0400 (EDT)
Message-ID: <51D2EDD7.9060205@suse.de>
Date: Tue, 02 Jul 2013 17:12:23 +0200
From: Alexander Graf <agraf@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH -V3 2/4] powerpc/kvm: Contiguous memory allocator based
 hash page table allocation
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372743918-12293-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

On 07/02/2013 07:45 AM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>
> Powerpc architecture uses a hash based page table mechanism for mapping virtual
> addresses to physical address. The architecture require this hash page table to
> be physically contiguous. With KVM on Powerpc currently we use early reservation
> mechanism for allocating guest hash page table. This implies that we need to
> reserve a big memory region to ensure we can create large number of guest
> simultaneously with KVM on Power. Another disadvantage is that the reserved memory
> is not available to rest of the subsystems and and that implies we limit the total
> available memory in the host.
>
> This patch series switch the guest hash page table allocation to use
> contiguous memory allocator.
>
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

Is CMA a mandatory option in the kernel? Or can it be optionally 
disabled? If it can be disabled, we should keep the preallocated 
fallback case around for systems that have CMA disabled.


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
