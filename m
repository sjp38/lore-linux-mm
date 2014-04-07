Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBAD6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:32:43 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 131so5677058ykp.12
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:32:43 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id a63si19606354yhk.189.2014.04.07.08.32.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:32:42 -0700 (PDT)
Message-ID: <5342C517.2020305@citrix.com>
Date: Mon, 7 Apr 2014 16:32:39 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <1396883443-11696-1-git-send-email-mgorman@suse.de> <1396883443-11696-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1396883443-11696-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 07/04/14 16:10, Mel Gorman wrote:
> _PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
> faults. As the bit is shared care is taken that _PAGE_NUMA is only used in
> places where _PAGE_PROTNONE could not reach but this still causes problems
> on Xen and conceptually difficult.

The problem with Xen guests occurred because mprotect() /was/ confusing
PROTNONE mappings with _PAGE_NUMA and clearing the non-existant NUMA hints.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
