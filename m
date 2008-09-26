Message-Id: <20080926173219.885155151@twins.programming.kicks-ass.net>
Date: Fri, 26 Sep 2008 19:32:19 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Since get_user_pages_fast() made it in, I thought to give this another try.
Lightly tested by disabling the private futexes and running some java proglets.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
