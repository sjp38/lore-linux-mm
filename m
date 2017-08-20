Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE316B04CD
	for <linux-mm@kvack.org>; Sun, 20 Aug 2017 08:15:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so32276598pfj.12
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 05:15:26 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id z73si6053674pfi.507.2017.08.20.05.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 05:15:25 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 123so19966954pga.5
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 05:15:25 -0700 (PDT)
Date: Sun, 20 Aug 2017 21:11:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170820121155.GA624@tigerII.localdomain>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On (08/18/17 00:05), Laurent Dufour wrote:
[..]
> +	/*
> +	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
> +	 * are not compatible with the speculative page fault processing.
> +	 */
> +	pol = __get_vma_policy(vma, address);
> +	if (!pol)
> +		pol = get_task_policy(current);
> +	if (pol && pol->mode == MPOL_INTERLEAVE)
> +		goto unlock;

include/linux/mempolicy.h defines

struct mempolicy *get_task_policy(struct task_struct *p);
struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
		unsigned long addr);

only for CONFIG_NUMA configs.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
