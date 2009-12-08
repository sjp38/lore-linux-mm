Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9532960021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 06:24:15 -0500 (EST)
Date: Tue, 8 Dec 2009 12:24:12 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: hwpoison madvise code
Message-ID: <20091208112412.GA6038@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>, fengguang.wu@intel.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Seems like the madvise hwpoison code is ugly and buggy, not to
put too fine a point on it :)

Ugly: it should have just followed the same pattern as the other
transient advices.
Buggy: it doesn't take mmap_sem. If it followed the pattern, it
wouldn't have had this bug.

Please fix.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
