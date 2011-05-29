Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B812B6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 03:23:06 -0400 (EDT)
Date: Sun, 29 May 2011 09:22:56 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [PATCH] mm: Fix boot crash in mm_alloc()
Message-ID: <20110529072256.GA20983@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org


Would be nice to get the fix below into -rc1 as well, it triggers 
rather easily on bootup when CONFIG_CPUMASK_OFFSTACK is turned on.

	Ingo

---------------------->
