Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 377006B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 18:21:52 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so60419394pab.3
        for <linux-mm@kvack.org>; Fri, 08 May 2015 15:21:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sn2si8713009pac.206.2015.05.08.15.21.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 15:21:51 -0700 (PDT)
Date: Fri, 8 May 2015 15:21:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 2/2] powerpc/thp: Serialize pmd clear against a linux
 page table walk.
Message-Id: <20150508152149.7fd52bb4b7c2a0911c33be00@linux-foundation.org>
In-Reply-To: <1430983408-24924-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1430983408-24924-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu,  7 May 2015 12:53:28 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Serialize against find_linux_pte_or_hugepte which does lock-less
> lookup in page tables with local interrupts disabled. For huge pages
> it casts pmd_t to pte_t. Since format of pte_t is different from
> pmd_t we want to prevent transit from pmd pointing to page table
> to pmd pointing to huge page (and back) while interrupts are disabled.
> We clear pmd to possibly replace it with page table pointer in
> different code paths. So make sure we wait for the parallel
> find_linux_pte_or_hugepage to finish.

I'm not seeing here any description of the problem which is being
fixed.  Does the patch make the machine faster?  Does the machine
crash?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
