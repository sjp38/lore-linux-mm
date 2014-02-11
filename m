Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2666B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:07:28 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id u14so6089569lbd.37
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:07:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kj3si10397586lbc.39.2014.02.11.09.07.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 09:07:27 -0800 (PST)
Date: Tue, 11 Feb 2014 17:07:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: Use ptep/pmdp_set_numa for updating _PAGE_NUMA
 bit
Message-ID: <20140211170724.GM6732@suse.de>
References: <1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1392114895-14997-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1392114895-14997-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 11, 2014 at 04:04:55PM +0530, Aneesh Kumar K.V wrote:
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

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
