Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 474B98D0041
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 16:07:57 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:06:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 13/20] lockdep, mutex: Provide mutex_lock_nest_lock
Message-Id: <20110419130654.95a14117.akpm@linux-foundation.org>
In-Reply-To: <20110401121725.940769985@chello.nl>
References: <20110401121258.211963744@chello.nl>
	<20110401121725.940769985@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Fri, 01 Apr 2011 14:13:11 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Provide the mutex_lock_nest_lock() annotation.

why?

Neither the changelog nor the code provide any documentation for this addition to
the lokdep API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
