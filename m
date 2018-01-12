Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B28116B0069
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 14:03:11 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e185so5705351pfg.23
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:03:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z8si15747518pfh.232.2018.01.12.11.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jan 2018 11:03:10 -0800 (PST)
Date: Fri, 12 Jan 2018 11:02:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 22/24] mm: Speculative page fault handler return VMA
Message-ID: <20180112190251.GC7590@bombadil.infradead.org>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-23-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515777968-867-23-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Jan 12, 2018 at 06:26:06PM +0100, Laurent Dufour wrote:
> @@ -1354,7 +1354,10 @@ extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  		unsigned int flags);
>  #ifdef CONFIG_SPF
>  extern int handle_speculative_fault(struct mm_struct *mm,
> +				    unsigned long address, unsigned int flags,
> +				    struct vm_area_struct **vma);

I think this shows that we need to create 'struct vm_fault' on the stack
in the arch code and then pass it to handle_speculative_fault(), followed
by handle_mm_fault().  That should be quite a nice cleanup actually.
I know that's only 30+ architectures to change ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
