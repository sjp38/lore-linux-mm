Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2766B000C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:47:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c11-v6so1466449pll.13
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 23:47:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i15sor496207pgp.155.2018.04.09.23.47.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 23:47:51 -0700 (PDT)
Date: Mon, 9 Apr 2018 23:47:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 21/24] perf tools: Add support for the SPF perf
 event
In-Reply-To: <20180327034936.GO13724@tassilo.jf.intel.com>
Message-ID: <alpine.DEB.2.21.1804092346090.225864@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-22-git-send-email-ldufour@linux.vnet.ibm.com> <alpine.DEB.2.20.1803261443560.255554@chino.kir.corp.google.com> <20180327034936.GO13724@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Mon, 26 Mar 2018, Andi Kleen wrote:

> > Aside: should there be a new spec_flt field for struct task_struct that 
> > complements maj_flt and min_flt and be exported through /proc/pid/stat?
> 
> No. task_struct is already too bloated. If you need per process tracking 
> you can always get it through trace points.
> 

Hi Andi,

We have

	count_vm_event(PGFAULT);
	count_memcg_event_mm(vma->vm_mm, PGFAULT);

in handle_mm_fault() but not counterpart for spf.  I think it would be 
helpful to be able to determine how much faulting can be done 
speculatively if there is no per-process tracking without tracing.
