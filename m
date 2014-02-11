Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0EF6B0038
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:49:50 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id f11so12239777qae.7
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:49:49 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id df5si1777685qcb.101.2014.02.11.10.49.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 10:49:47 -0800 (PST)
Message-ID: <1392144570.23418.8.camel@pasglop>
Subject: Re: [PATCH 3/3] mm: Use ptep/pmdp_set_numa for updating _PAGE_NUMA
 bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Feb 2014 05:49:30 +1100
In-Reply-To: <20140211170724.GM6732@suse.de>
References: 
	<1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1392114895-14997-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20140211170724.GM6732@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, riel@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2014-02-11 at 17:07 +0000, Mel Gorman wrote:
> On Tue, Feb 11, 2014 at 04:04:55PM +0530, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Archs like ppc64 doesn't do tlb flush in set_pte/pmd functions. ppc64 also doesn't implement
> > flush_tlb_range. ppc64 require the tlb flushing to be batched within ptl locks. The reason
> > to do that is to ensure that the hash page table is in sync with linux page table.
> > We track the hpte index in linux pte and if we clear them without flushing hash and drop the
> > ptl lock, we can have another cpu update the pte and can end up with double hash. We also want
> > to keep set_pte_at simpler by not requiring them to do hash flush for performance reason.
> > Hence cannot use them while updating _PAGE_NUMA bit. Add new functions for marking pte/pmd numa
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 

How do you guys want me to proceed ? Will you (or Andrew) send these to
Linus or should I do it myself ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
