Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E53A66B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:49:41 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id z2so5358775wiv.0
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:49:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vj2si6395842wjc.184.2014.04.07.08.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:49:40 -0700 (PDT)
Date: Mon, 7 Apr 2014 16:49:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407154935.GD7292@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5342C517.2020305@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 07, 2014 at 04:32:39PM +0100, David Vrabel wrote:
> On 07/04/14 16:10, Mel Gorman wrote:
> > _PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
> > faults. As the bit is shared care is taken that _PAGE_NUMA is only used in
> > places where _PAGE_PROTNONE could not reach but this still causes problems
> > on Xen and conceptually difficult.
> 
> The problem with Xen guests occurred because mprotect() /was/ confusing
> PROTNONE mappings with _PAGE_NUMA and clearing the non-existant NUMA hints.
> 

I didn't bother spelling it out in case I gave the impression that I was
blaming Xen for the problem.  As the bit is now changes, does it help
the Xen problem or cause another collision of some sort? There is no
guarantee _PAGE_NUMA will remain as bit 62 but at worst it'll use bit 11
and NUMA_BALANCING will depend in !KMEMCHECK.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
