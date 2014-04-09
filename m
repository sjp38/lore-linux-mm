Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB5B6B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 02:21:11 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so1439415eek.4
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 23:21:10 -0700 (PDT)
Received: from mail-ee0-x22f.google.com (mail-ee0-x22f.google.com [2a00:1450:4013:c00::22f])
        by mx.google.com with ESMTPS id l41si5661eef.158.2014.04.08.23.21.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 23:21:09 -0700 (PDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1426901eek.34
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 23:21:07 -0700 (PDT)
Date: Wed, 9 Apr 2014 08:21:03 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
Message-ID: <20140409062103.GA7294@gmail.com>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
 <53440A5D.6050301@zytor.com>
 <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
 <20140408164652.GL7292@suse.de>
 <20140408173031.GS10526@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408173031.GS10526@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Apr 08, 2014 at 05:46:52PM +0100, Mel Gorman wrote:
> > Someone will ask why automatic NUMA balancing hints do not use "real"
> > PROT_NONE but as it would need VMA information to do that on all
> > architectures it would mean that VMA-fixups would be required when marking
> > PTEs for NUMA hinting faults so would be expensive.
> 
> Like this:
> 
>   https://lkml.org/lkml/2012/11/13/431
> 
> That used the generic PROT_NONE infrastructure and compared, on fault,
> the page protection bits against the vma->vm_page_prot bits?
> 
> So the objection to that approach was the vma-> dereference in
> pte_numa() ?

I think the real underlying objection was that PTE_NUMA was the last 
leftover from AutoNUMA, and removing it would have made it not a 
'compromise' patch set between 'AutoNUMA' and 'sched/numa', but would 
have made the sched/numa approach 'win' by and large.

The whole 'losing face' annoyance that plagues all of us (me 
included).

I didn't feel it was important to the general logic of adding access 
pattern aware NUMA placement logic to the scheduler, and I obviously 
could not ignore the NAKs from various mm folks insisting on PTE_NUMA, 
so I conceded that point and Mel built on that approach as well.

Nice it's being cleaned up, and I'm pretty happy about how NUMA 
balancing ended up looking like.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
