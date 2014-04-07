Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 07BA96B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 12:19:14 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so4914619lab.6
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 09:19:13 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id y6si12662332lal.131.2014.04.07.09.19.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 09:19:12 -0700 (PDT)
Received: by mail-la0-f42.google.com with SMTP id ec20so5090279lab.1
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 09:19:11 -0700 (PDT)
Date: Mon, 7 Apr 2014 20:19:10 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407161910.GJ1444@moon>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140407154935.GD7292@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 04:49:35PM +0100, Mel Gorman wrote:
> On Mon, Apr 07, 2014 at 04:32:39PM +0100, David Vrabel wrote:
> > On 07/04/14 16:10, Mel Gorman wrote:
> > > _PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
> > > faults. As the bit is shared care is taken that _PAGE_NUMA is only used in
> > > places where _PAGE_PROTNONE could not reach but this still causes problems
> > > on Xen and conceptually difficult.
> > 
> > The problem with Xen guests occurred because mprotect() /was/ confusing
> > PROTNONE mappings with _PAGE_NUMA and clearing the non-existant NUMA hints.
> 
> I didn't bother spelling it out in case I gave the impression that I was
> blaming Xen for the problem.  As the bit is now changes, does it help
> the Xen problem or cause another collision of some sort? There is no
> guarantee _PAGE_NUMA will remain as bit 62 but at worst it'll use bit 11
> and NUMA_BALANCING will depend in !KMEMCHECK.

Fwiw, we're using bit 11 for soft-dirty tracking, so i really hope worst case
never happen. (At the moment I'm trying to figure out if with this set
it would be possible to clean up ugly macros in pgoff_to_pte for 2 level pages).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
