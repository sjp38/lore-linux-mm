Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 870366B0036
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:28:10 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so7355157wgh.22
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:28:09 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id dh4si6643348wjc.167.2014.04.07.12.28.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 12:28:05 -0700 (PDT)
Message-ID: <5342FC0E.9080701@zytor.com>
Date: Mon, 07 Apr 2014 12:27:10 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <1396883443-11696-1-git-send-email-mgorman@suse.de> <1396883443-11696-3-git-send-email-mgorman@suse.de> <5342C517.2020305@citrix.com> <20140407154935.GD7292@suse.de> <20140407161910.GJ1444@moon> <20140407182854.GH7292@suse.de>
In-Reply-To: <20140407182854.GH7292@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 04/07/2014 11:28 AM, Mel Gorman wrote:
> 
> I had considered the soft-dirty tracking usage of the same bit. I thought I'd
> be able to swizzle around it or a further worst case of having soft-dirty and
> automatic NUMA balancing mutually exclusive. Unfortunately upon examination
> it's not obvious how to have both of them share a bit and I suspect any
> attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
> set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
> list is examining if _PAGE_BIT_IOMAP can be used.
> 

Didn't we smoke the last user of _PAGE_BIT_IOMAP?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
