Date: Sat, 6 Nov 2004 02:31:03 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041106103103.GC2890@holomorphy.com>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au> <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au> <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418CA535.1030703@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>> My page scalability patches need to make rss atomic and now with the
>> addition of anon_rss I would also have to make that atomic.

> 
On Sat, Nov 06, 2004 at 09:19:33PM +1100, Nick Piggin wrote:
> Oh, one other thing Christoph - don't forget mm->nr_ptes

Forget it. Veto.

Normal-sized systems need to monitor their workloads without crippling
them. Do the per-cpu splitting of the counters etc. instead, or other
proper incremental algorithms. Catastrophic /proc/ overhead won't fly.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
