Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 46E756B0095
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 05:31:40 -0400 (EDT)
Received: by mail-yk0-f171.google.com with SMTP id q9so552636ykb.30
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 02:31:38 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id m27si1719479yha.60.2014.04.08.02.31.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 02:31:38 -0700 (PDT)
Message-ID: <5343C1F6.4090600@citrix.com>
Date: Tue, 8 Apr 2014 10:31:34 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <1396883443-11696-1-git-send-email-mgorman@suse.de> <1396883443-11696-3-git-send-email-mgorman@suse.de> <5342C517.2020305@citrix.com> <20140407154935.GD7292@suse.de> <20140407161910.GJ1444@moon> <20140407182854.GH7292@suse.de> <5342FC0E.9080701@zytor.com> <20140407193646.GC23983@moon>
In-Reply-To: <20140407193646.GC23983@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 07/04/14 20:36, Cyrill Gorcunov wrote:
> On Mon, Apr 07, 2014 at 12:27:10PM -0700, H. Peter Anvin wrote:
>> On 04/07/2014 11:28 AM, Mel Gorman wrote:
>>>
>>> I had considered the soft-dirty tracking usage of the same bit. I thought I'd
>>> be able to swizzle around it or a further worst case of having soft-dirty and
>>> automatic NUMA balancing mutually exclusive. Unfortunately upon examination
>>> it's not obvious how to have both of them share a bit and I suspect any
>>> attempt to will break CRIU.  In my current tree, NUMA_BALANCING cannot be
>>> set if MEM_SOFT_DIRTY which is not particularly satisfactory. Next on the
>>> list is examining if _PAGE_BIT_IOMAP can be used.
>>
>> Didn't we smoke the last user of _PAGE_BIT_IOMAP?

Not yet.

A last minute regression with mapping of I/O regions from userspace was
found so I had to drop the series from 3.15.  It should be back for 3.16.

> Seems so, at least for non-kernel pages (not considering this bit references in
> xen code, which i simply don't know but i guess it's used for kernel pages only).

Xen uses it for all I/O mappings, both kernel and for userspace.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
