Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id E51806B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 15:25:15 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so169315qac.6
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 12:25:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si22854691qaz.79.2013.12.05.12.25.13
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 12:25:14 -0800 (PST)
Message-ID: <52A0E12E.8050105@redhat.com>
Date: Thu, 05 Dec 2013 15:25:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V3] mm: Move change_prot_numa outside CONFIG_ARCH_USES_NUMA_PROT_NONE
References: <1386268702-30806-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1386268702-30806-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mgorman@suse.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 12/05/2013 01:38 PM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> change_prot_numa should work even if _PAGE_NUMA != _PAGE_PROTNONE.
> On archs like ppc64 that don't use _PAGE_PROTNONE and also have
> a separate page table outside linux pagetable, we just need to
> make sure that when calling change_prot_numa we flush the
> hardware page table entry so that next page access  result in a numa
> fault.
>
> We still need to make sure we use the numa faulting logic only
> when CONFIG_NUMA_BALANCING is set. This implies the migrate-on-fault
> (Lazy migration) via mbind will only work if CONFIG_NUMA_BALANCING
> is set.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
