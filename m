Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9E76B0003
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 19:00:19 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so6902010pla.18
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 16:00:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c12-v6sor588136pll.103.2018.04.02.16.00.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 16:00:17 -0700 (PDT)
Date: Mon, 2 Apr 2018 16:00:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 12/24] mm/migrate: Pass vm_fault pointer to
 migrate_misplaced_page()
In-Reply-To: <1520963994-28477-13-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804021559560.94516@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-13-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> migrate_misplaced_page() is only called during the page fault handling so
> it's better to pass the pointer to the struct vm_fault instead of the vma.
> 
> This way during the speculative page fault path the saved vma->vm_flags
> could be used.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>
