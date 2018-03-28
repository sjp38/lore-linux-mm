Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 655F36B005A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:20:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m134-v6so2103798itb.9
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:20:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w198sor1495720iof.126.2018.03.28.03.20.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 03:20:26 -0700 (PDT)
Date: Wed, 28 Mar 2018 03:20:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 06/24] mm: make pte_unmap_same compatible with SPF
In-Reply-To: <fd9eedf4-b885-d8f5-2daa-4cc450e72427@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803280318440.69353@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-7-git-send-email-ldufour@linux.vnet.ibm.com> <alpine.DEB.2.20.1803271417510.31115@chino.kir.corp.google.com>
 <fd9eedf4-b885-d8f5-2daa-4cc450e72427@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Wed, 28 Mar 2018, Laurent Dufour wrote:

> >> @@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
> >>  	int exclusive = 0;
> >>  	int ret = 0;
> > 
> > Initialization is now unneeded.
> 
> I'm sorry, what "initialization" are you talking about here ?
> 

The initialization of the ret variable.

@@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
+	ret = pte_unmap_same(vmf);
+	if (ret)
 		goto out;
 
 	entry = pte_to_swp_entry(vmf->orig_pte);

"ret" is immediately set to the return value of pte_unmap_same(), so there 
is no need to initialize it to 0.
