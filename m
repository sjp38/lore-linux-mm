Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 445DB6B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:13:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o202so9747209itc.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:13:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r21si705331ita.99.2017.07.06.09.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:13:12 -0700 (PDT)
Date: Thu, 6 Jul 2017 18:13:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 09/11] mm: Try spin lock in speculative path
Message-ID: <20170706161302.aupbhvld3yew3cjl@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170705185023.xlqko7wgepwsny5g@hirez.programming.kicks-ass.net>
 <3af22f3b-03ab-1d37-b2b1-b616adde7eb6@linux.vnet.ibm.com>
 <20170706144852.fwtuygj4ikcjmqat@hirez.programming.kicks-ass.net>
 <ce7a039a-2697-f16e-b0b3-f6ae41391682@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce7a039a-2697-f16e-b0b3-f6ae41391682@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Thu, Jul 06, 2017 at 05:29:26PM +0200, Laurent Dufour wrote:
> Based on the benchmarks I run, it doesn't fail so much often, but I was
> thinking about adding some counters here. The system is accounting for
> major page faults and minor ones, respectively current->maj_flt and
> current->min_flt. I was wondering if an additional type like async_flt will
> be welcome or if there is another smarter way to get that metric.
> 
> Feel free to advise.

You could stick a tracepoint in, or extend PERF_COUNT_SW_PAGE_FAULTS*.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
