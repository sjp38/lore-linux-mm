Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 01A4A6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:30:40 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so1270600iec.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:30:39 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id pe7si2752016icc.186.2014.04.08.10.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 10:30:39 -0700 (PDT)
Date: Tue, 8 Apr 2014 19:30:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
Message-ID: <20140408173031.GS10526@twins.programming.kicks-ass.net>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
 <53440A5D.6050301@zytor.com>
 <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
 <20140408164652.GL7292@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408164652.GL7292@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 08, 2014 at 05:46:52PM +0100, Mel Gorman wrote:
> Someone will ask why automatic NUMA balancing hints do not use "real"
> PROT_NONE but as it would need VMA information to do that on all
> architectures it would mean that VMA-fixups would be required when marking
> PTEs for NUMA hinting faults so would be expensive.

Like this:

  https://lkml.org/lkml/2012/11/13/431

That used the generic PROT_NONE infrastructure and compared, on fault,
the page protection bits against the vma->vm_page_prot bits?

So the objection to that approach was the vma-> dereference in
pte_numa() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
