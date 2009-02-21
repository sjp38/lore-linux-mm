Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE566B007E
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 10:23:18 -0500 (EST)
Date: Sat, 21 Feb 2009 16:23:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] kmemcheck: add hooks for the page allocator
Message-ID: <20090221152310.GB6460@elte.hu>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com> <1235223364-2097-5-git-send-email-vegard.nossum@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235223364-2097-5-git-send-email-vegard.nossum@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> This adds support for tracking the initializedness of memory 
> that was allocated with the page allocator. Highmem requests 
> are not tracked.

yeah - highmem pages are also rather uninteresting, as if 
there's any uninitialized use going on we'll trigger it with 
lowmem pages too - there's no highmem-only allocations in the 
kernel.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
