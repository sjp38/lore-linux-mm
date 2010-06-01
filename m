Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECB3B6B01E0
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 11:48:15 -0400 (EDT)
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
From: Andi Kleen <andi@firstfloor.org>
References: <20100601073343.GQ9453@laptop>
Date: Tue, 01 Jun 2010 17:48:10 +0200
In-Reply-To: <20100601073343.GQ9453@laptop> (Nick Piggin's message of "Tue\, 1 Jun 2010 17\:33\:43 +1000")
Message-ID: <87wruiycsl.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee@firstfloor.org, Schermerh@firstfloor.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

> This isn't really a new problem, and I don't know how important it is,
> but I recently came across it again when doing some aim7 testing with
> huge numbers of tasks.

Seems reasonable. Of course you need to at least 
save/restore the old CPU policy, and use a subset of it.

Another approach would be to migrate this on touch, but that is probably
slightly more difficult. The advantage would be that on multiple
migrations it would follow. And it would be a bit slower for
the initial case.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
