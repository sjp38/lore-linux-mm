Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F013A6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 16:38:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so5495494pfd.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 13:38:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u10si1994341pgp.240.2017.09.28.13.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 13:38:52 -0700 (PDT)
Date: Thu, 28 Sep 2017 13:38:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 00/20] Speculative page faults
Message-Id: <20170928133850.90c5bf2aac0f1a63e29c01a3@linux-foundation.org>
In-Reply-To: <924a79af-6d7a-316a-1eee-3aebbfd4addf@linux.vnet.ibm.com>
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
	<20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
	<924a79af-6d7a-316a-1eee-3aebbfd4addf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On Thu, 28 Sep 2017 14:29:02 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> > Laurent's [0/n] provides some nice-looking performance benefits for
> > workloads which are chosen to show performance benefits(!) but, alas,
> > no quantitative testing results for workloads which we may suspect will
> > be harmed by the changes(?).  Even things as simple as impact upon
> > single-threaded pagefault-intensive workloads and its effect upon
> > CONFIG_SMP=n .text size?
> 
> I forgot to mention in my previous email the impact on the .text section.
> 
> Here are the metrics I got :
> 
> .text size	UP		SMP		Delta
> 4.13-mmotm	8444201		8964137		6.16%
> '' +spf		8452041		8971929		6.15%
> 	Delta	0.09%		0.09%	
> 
> No major impact as you could see.

8k text increase seems rather a lot actually.  That's a lot more
userspace cacheclines that get evicted during a fault...

Is the feature actually beneficial on uniprocessor?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
