Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 860076B026C
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:27:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l23so12346312pgc.10
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:27:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q61sor3842423plb.97.2017.11.06.02.27.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 02:27:32 -0800 (PST)
Date: Mon, 6 Nov 2017 19:27:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [v5,22/22] powerpc/mm: Add speculative page fault
Message-ID: <20171106102726.GB1298@jagdpanzerIV>
References: <1507729966-10660-23-git-send-email-ldufour@linux.vnet.ibm.com>
 <7ca80231-fe02-a3a7-84bc-ce81690ea051@intel.com>
 <c0b7f172-5d9c-eec6-540d-216b908f005f@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0b7f172-5d9c-eec6-540d-216b908f005f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: kemi <kemi.wang@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On (11/02/17 15:11), Laurent Dufour wrote:
> On 26/10/2017 10:14, kemi wrote:
> > Some regression is found by LKP-tools(linux kernel performance) on this patch series
> > tested on Intel 2s/4s Skylake platform. 
> > The regression result is sorted by the metric will-it-scale.per_process_ops.
> 
> Hi Kemi,
> 
> Thanks for reporting this, I'll try to address it by turning some features
> of the SPF path off when the process is monothreaded.

make them madvice()-able?
not all multi-threaded apps will necessarily benefit of SPF. right?
just an idea.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
