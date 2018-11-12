Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD4A56B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 15:37:43 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z68so1789501qkb.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 12:37:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor14361231qvm.61.2018.11.12.12.37.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 12:37:42 -0800 (PST)
Date: Mon, 12 Nov 2018 20:37:37 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Message-ID: <20181112203737.e4jnsp4rxpie4trr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
 <18b6634b912af7b4ec01396a2b0f3b31737c9ea2.camel@linux.intel.com>
 <20181110000006.tmcfnzynelaznn7u@xakep.localdomain>
 <0d8782742d016565870c578848138aaedf873a7c.camel@linux.intel.com>
 <20181110011652.2wozbvfimcnhogfj@xakep.localdomain>
 <CAKgT0UdDYC5RvZ1XgLTamFpBe3foPMs+SV_kSUVNDWLvxSC_1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UdDYC5RvZ1XgLTamFpBe3foPMs+SV_kSUVNDWLvxSC_1Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, alexander.h.duyck@linux.intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm <linux-mm@kvack.org>, sparclinux@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, David Miller <davem@davemloft.net>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, Mel Gorman <mgorman@techsingularity.net>, yi.z.zhang@linux.intel.com

On 18-11-12 11:10:35, Alexander Duyck wrote:
> 
> The point I was trying to make is that it doesn't. You say it is an
> order of magnitude better but it is essentially 3.5x vs 3.8x and to
> achieve the 3.8x you are using a ton of system resources. My approach
> is meant to do more with less, while this approach will throw a
> quarter of the system at  page initialization.

3.8x is a bug, that is going to be fixed before ktasks are accepted. The
final results will be close to time/nthreads.
Using more resources to initialize pages is fine, because other CPUs are
idling during this time in boot.

Lets wait for what Daniel finds out after Linux Plumber. And we can
continue this discussion in ktask thread.

> 
> An added advantage to my approach is that it speeds up things
> regardless of the number of cores used, whereas the scaling approach

Yes, I agree, I like your approach. It is clean, simplifies, and
improves the performance. I have tested it on both ARM and x86, and
verified the performance improvements. So:

Tested-by: Pavel Tatashin <pasha.tatashin@soleen.com>


> requires that there be more cores available to use. So for example on
> some of the new AMD Zen stuff I am not sure the benefit would be all
> that great since if I am not mistaken each tile is only 8 processors
> so at most you are only doubling the processing power applied to the
> initialization. In such a case it is likely that my approach would
> fare much better then this approach since I don't require additional
> cores to achieve the same results.
> 
> Anyway there are tradeoffs we have to take into account.
> 
> I will go over the changes you suggested after Plumbers. I just need
> to figure out if I am doing incremental changes, or if Andrew wants me
> to just resubmit the whole set. I can probably deal with these changes
> either way since most of them are pretty small.

Send the full series again, Andrew is very good at taking only
incremental  changes once a new version is posted of something
that is already in mm-tree.

Thank you,
Pasha
