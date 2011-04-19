Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 33EEF8D0041
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 16:08:04 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:07:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 15/20] mm: Convert i_mmap_lock to a mutex
Message-Id: <20110419130725.38cb638b.akpm@linux-foundation.org>
In-Reply-To: <20110401121726.037173835@chello.nl>
References: <20110401121258.211963744@chello.nl>
	<20110401121726.037173835@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, 01 Apr 2011 14:13:13 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Straight fwd conversion of i_mmap_lock to a mutex

What effect does this have on kernel performance?

Workloads which take the lock at high frequency from multiple threads
should be tested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
