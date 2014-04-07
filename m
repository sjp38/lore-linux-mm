Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1892C6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:36:49 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id ec20so5222769lab.15
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:36:49 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id e6si13012013lah.79.2014.04.07.12.36.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 12:36:48 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id u14so5183767lbd.19
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:36:48 -0700 (PDT)
Date: Mon, 7 Apr 2014 23:36:46 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140407193646.GC23983@moon>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
 <1396883443-11696-3-git-send-email-mgorman@suse.de>
 <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5342FC0E.9080701@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Apr 07, 2014 at 12:27:10PM -0700, H. Peter Anvin wrote:
> On 04/07/2014 11:28 AM, Mel Gorman wrote:
> > 
> > I had considered the soft-dirty tracking usage of the same bit. I thought I'd
> > be able to swizzle around it or a further worst case of having soft-dirty and
> > automatic NUMA balancing mutually exclusive. Unfortunately upon examination
> > it's not obvious how to have both of them share a bit and I suspect any
> > attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
> > set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
> > list is examining if _PAGE_BIT_IOMAP can be used.
> 
> Didn't we smoke the last user of _PAGE_BIT_IOMAP?

Seems so, at least for non-kernel pages (not considering this bit references in
xen code, which i simply don't know but i guess it's used for kernel pages only).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
