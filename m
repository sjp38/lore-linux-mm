Message-ID: <418CAA44.3090007@yahoo.com.au>
Date: Sat, 06 Nov 2004 21:41:08 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au> <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au> <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au> <20041106103103.GC2890@holomorphy.com>
In-Reply-To: <20041106103103.GC2890@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> Christoph Lameter wrote:
> 
>>>My page scalability patches need to make rss atomic and now with the
>>>addition of anon_rss I would also have to make that atomic.
> 
> 
> On Sat, Nov 06, 2004 at 09:19:33PM +1100, Nick Piggin wrote:
> 
>>Oh, one other thing Christoph - don't forget mm->nr_ptes
> 
> 
> Forget it. Veto.
> 
> Normal-sized systems need to monitor their workloads without crippling
> them. Do the per-cpu splitting of the counters etc. instead, or other
> proper incremental algorithms. Catastrophic /proc/ overhead won't fly.
> 

Out of interest, what sort of systems and workloads are we talking
about here?

Also, can you suggest how one would do the per-cpu splitting or
other proper incremental algorithm? I am not aware of any way
except per-cpu magazines which I presume also won't fly due to
being inaccurate and hugely bloating the mm_struct on big machines.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
