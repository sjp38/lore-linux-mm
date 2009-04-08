Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C70675F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 02:46:02 -0400 (EDT)
Subject: Re: [PATCH 1/2] Avoid putting a bad page back on the LRU
From: Andi Kleen <andi@firstfloor.org>
References: <20090408001133.GB27170@sgi.com>
	<200904080543.16454.ioe-lkml@rameria.de>
Date: Wed, 08 Apr 2009 08:46:41 +0200
In-Reply-To: <200904080543.16454.ioe-lkml@rameria.de> (Ingo Oeser's message of "Wed, 8 Apr 2009 05:43:15 +0200")
Message-ID: <87r603abhq.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: Russ Anderson <rja@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser <ioe-lkml@rameria.de> writes:
>
> Clearing the flag doesn't change the fact, that this page is representing 
> permanently bad RAM.

Yes, you cannot ever clear a Poison flag, at least not without a special
hardware mechanism that clears the hardware poison too (but that has
other issues in Linux too). Otherwise you would die later.

> What about removing it from the LRU and adding it to a bad RAM list in every case?

That is what memory_failure() already should be doing. Except there's no list
currently.

> After hot swapping the physical RAM banks it could be moved back, not before.

Linux doesn't really support that. That is at least not when it's OS visible.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
