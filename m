Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDD8B6B0518
	for <linux-mm@kvack.org>; Thu, 17 May 2018 13:20:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20-v6so3072516pff.14
        for <linux-mm@kvack.org>; Thu, 17 May 2018 10:20:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w22-v6si5182525pll.599.2018.05.17.10.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 10:20:29 -0700 (PDT)
Date: Thu, 17 May 2018 10:19:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 01/26] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
Message-ID: <20180517171951.GB26718@bombadil.infradead.org>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1526555193-7242-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <2cb8256d-5822-d94d-b0e6-c46f21d84852@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2cb8256d-5822-d94d-b0e6-c46f21d84852@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Thu, May 17, 2018 at 09:36:00AM -0700, Randy Dunlap wrote:
> > +	 If the speculative page fault fails because of a concurrency is
> 
> 	                                     because a concurrency is

While one can use concurrency as a noun, it sounds archaic to me.  I'd
rather:

	If the speculative page fault fails because a concurrent modification
	is detected or because underlying PMD or PTE tables are not yet

> > +	 detected or because underlying PMD or PTE tables are not yet
> > +	 allocating, it is failing its processing and a classic page fault
> 
> 	 allocated, the speculative page fault fails and a classic page fault
> 
> > +	 is then tried.
