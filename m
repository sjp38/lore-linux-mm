Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id B2D226B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:15:00 -0400 (EDT)
Date: Wed, 10 Apr 2013 17:14:53 +1000
From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
Message-ID: <20130410071453.GB24786@concordia>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We allocate one page for the last level of linux page table. With THP and
> large page size of 16MB, that would mean we are wasting large part
> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
> page size. This patch reduce the space wastage by sharing the page
> allocated for the last level of linux page table with multiple pmd
> entries. We call these smaller chunks PTE page fragments and allocated
> page, PTE page.

This is not compiling for me:

arch/powerpc/mm/mmu_context_hash64.c:118:3: error: implicit declaration of function 'reset_page_mapcount'

And similar.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
