Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id A76B86B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:25:54 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id c9so12966752qcz.13
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:25:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d69si12370072qge.38.2014.02.11.05.25.53
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 05:25:54 -0800 (PST)
Message-ID: <52FA24D9.3040406@redhat.com>
Date: Tue, 11 Feb 2014 08:25:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Use ptep/pmdp_set_numa for updating _PAGE_NUMA
 bit
References: <1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1392114895-14997-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1392114895-14997-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 02/11/2014 05:34 AM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Archs like ppc64 doesn't do tlb flush in set_pte/pmd functions. ppc64 also doesn't implement
> flush_tlb_range. ppc64 require the tlb flushing to be batched within ptl locks. The reason
> to do that is to ensure that the hash page table is in sync with linux page table.
> We track the hpte index in linux pte and if we clear them without flushing hash and drop the
> ptl lock, we can have another cpu update the pte and can end up with double hash. We also want
> to keep set_pte_at simpler by not requiring them to do hash flush for performance reason.
> Hence cannot use them while updating _PAGE_NUMA bit. Add new functions for marking pte/pmd numa
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
