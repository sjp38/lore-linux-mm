Message-ID: <46136E94.2060106@yahoo.com.au>
Date: Wed, 04 Apr 2007 19:23:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <4612DCC6.7000504@cosmosbay.com> <46130BC8.9050905@yahoo.com.au> <1175675146.6483.26.camel@twins> <461367F6.10705@yahoo.com.au> <20070404091230.GJ2986@holomorphy.com>
In-Reply-To: <20070404091230.GJ2986@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric Dumazet <dada1@cosmosbay.com>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Wed, Apr 04, 2007 at 06:55:18PM +1000, Nick Piggin wrote:
> 
>>+		rcu_read_lock();
>>+		do {
>>+			t->vma_cache_sequence = -1;
>>+			t = next_thread(t);
>>+		} while (t != curr);
>>+		rcu_read_unlock();
> 
> 
> LD_ASSUME_KERNEL=2.4.18 anyone?

Meaning?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
