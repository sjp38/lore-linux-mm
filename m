Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE3B6B02A4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:31 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765ChLP010286
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:12:43 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FS741200136
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:28 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FSnS020267
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:28 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: memblock updates
Date: Fri,  6 Aug 2010 15:14:41 +1000
Message-Id: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi folks !

Here's my current branch. This time build tested on sparc(64), arm,
powerpc and sh. I don't have a microblaze compiler at hand.

Not much difference from the previous one. Off the top of my head:

 - Added the memblock_is_region_reserved() fix at the beginning
   (I'll send that to Linus separately if we decide this series
   shouldn't go in 2.6.36)
 - Split the patch adding the new accessors into separate patches
   for adding the accessors, converting each arch, and removing
   the old accessors. This makes it clearer, easier to review,
   etc... I added a couple new accessors for ARM.
 - Added the ARM updates based on what's upstream now (involves
   new memblock_is_memory() and memblock_is_memory_region() for
   use by ARM, nothing fancy there).

So very little changes. I haven't changed the init sections so
the warnings reported by Steven are still there. I will fix them
as an addon patch as I don't believe there's any actual breakage.

Now, what do you guys want to do with this now ? I can ask Linus
to pull now or we can wait until the end of the merge window and
put it into -next for another round...

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
