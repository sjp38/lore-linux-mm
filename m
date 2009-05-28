Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 255D46B004F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 05:02:45 -0400 (EDT)
Subject: Re: [PATCH] [9/16] HWPOISON: Use bitmask/action code for try_to_unmap behaviour
From: Andi Kleen <andi@firstfloor.org>
References: <200905271012.668777061@firstfloor.org>
	<20090527201235.9475E1D0292@basil.firstfloor.org>
	<20090528072703.GF6920@wotan.suse.de>
	<20090528080319.GA1065@one.firstfloor.org>
	<20090528082818.GH6920@wotan.suse.de>
Date: Thu, 28 May 2009 11:02:41 +0200
In-Reply-To: <20090528082818.GH6920@wotan.suse.de> (Nick Piggin's message of "Thu, 28 May 2009 10:28:18 +0200")
Message-ID: <874ov5fvm6.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

> There are a set of "actions" which is what the callers are, then a
> set of modifiers. Just make it all modifiers and the callers can
> use things that are | together.

The actions are typically contradictory in some way, that is why
I made them "actions". The modifiers are all things that could
be made into flags in a straightforward way.

Probably it could be all turned into flags, but that would
make the patch much more intrusive for rmap.c than it currently is,
with some restructuring needed, which I didn't want to do.

Hwpoison in general is designed to not be intrusive.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
