Date: Wed, 4 Apr 2007 02:12:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: missing madvise functionality
Message-ID: <20070404091230.GJ2986@holomorphy.com>
References: <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <4612DCC6.7000504@cosmosbay.com> <46130BC8.9050905@yahoo.com.au> <1175675146.6483.26.camel@twins> <461367F6.10705@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <461367F6.10705@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric Dumazet <dada1@cosmosbay.com>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 06:55:18PM +1000, Nick Piggin wrote:
> +		rcu_read_lock();
> +		do {
> +			t->vma_cache_sequence = -1;
> +			t = next_thread(t);
> +		} while (t != curr);
> +		rcu_read_unlock();

LD_ASSUME_KERNEL=2.4.18 anyone?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
