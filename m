Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1228145238.18834.29.camel@lts-notebook>
References: <1227886959.4454.4421.camel@twins>
	 <Pine.LNX.4.64.0812010747100.11954@quilx.com>
	 <1228142895.7140.43.camel@twins>  <1228145238.18834.29.camel@lts-notebook>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 01 Dec 2008 16:33:30 +0100
Message-Id: <1228145610.7070.18.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 10:27 -0500, Lee Schermerhorn wrote:
> mlock(), mprotect() and mbind() [others?] can also split/merge vmas
> under exclusive mmap_sem to accomodate the changed attributes.

Right, all those should be OK as described in the Split/Merge scenarios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
