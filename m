Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F29D1280272
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:04:22 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 61so7307283plz.3
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 19:04:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m5si2825310pgd.250.2018.01.16.19.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 19:04:21 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v6 03/24] mm: Dont assume page-table invariance during faults
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1515777968-867-4-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Tue, 16 Jan 2018 19:04:12 -0800
In-Reply-To: <1515777968-867-4-git-send-email-ldufour@linux.vnet.ibm.com>
	(Laurent Dufour's message of "Fri, 12 Jan 2018 18:25:47 +0100")
Message-ID: <87d129tccz.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> From: Peter Zijlstra <peterz@infradead.org>
>
> One of the side effects of speculating on faults (without holding
> mmap_sem) is that we can race with free_pgtables() and therefore we
> cannot assume the page-tables will stick around.
>
> Remove the reliance on the pte pointer.

This needs a lot more explanation. So why is this code not needed with
SPF only?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
