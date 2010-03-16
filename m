Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 85E7B6B013B
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 02:20:39 -0400 (EDT)
Date: Tue, 16 Mar 2010 07:20:32 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [rfc][patch] mm: lockdep page lock
Message-ID: <20100316062032.GB22651@elte.hu>
References: <20100315155859.GE2869@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100315155859.GE2869@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* Nick Piggin <npiggin@suse.de> wrote:

> Page lock has very complex dependencies, so it would be really nice to add 
> lockdep support for it.

Just wondering - has your patch shown any suspect areas of code already, in 
the testing you did?

Maybe it should be test-driven for a while, in a non-append-only tree such as 
-mm, to see whether it's finding real bugs.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
