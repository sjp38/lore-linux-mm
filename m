Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E368F6B002E
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 17:50:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z13so4771138pgu.5
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 14:50:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1-v6sor6036306plk.115.2018.03.25.14.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 14:50:05 -0700 (PDT)
Date: Sun, 25 Mar 2018 14:50:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 01/24] mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
In-Reply-To: <1520963994-28477-2-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803251442090.80485@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> This configuration variable will be used to build the code needed to
> handle speculative page fault.
> 
> By default it is turned off, and activated depending on architecture
> support.
> 
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/Kconfig | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index abefa573bcd8..07c566c88faf 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -759,3 +759,6 @@ config GUP_BENCHMARK
>  	  performance of get_user_pages_fast().
>  
>  	  See tools/testing/selftests/vm/gup_benchmark.c
> +
> +config SPECULATIVE_PAGE_FAULT
> +       bool

Should this be configurable even if the arch supports it?
