Message-ID: <418D7235.7010501@yahoo.com.au>
Date: Sun, 07 Nov 2004 11:54:13 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au> <20041106103103.GC2890@holomorphy.com> <418CAA44.3090007@yahoo.com.au> <20041106105314.GD2890@holomorphy.com> <418CB06F.1080405@yahoo.com.au> <20041106120624.GE2890@holomorphy.com> <418CBED7.6050609@yahoo.com.au> <20041106122355.GF2890@holomorphy.com>
In-Reply-To: <20041106122355.GF2890@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> William Lee Irwin III wrote:
> 
>>>There is no conflict. The sums are invariant under overflows.
> 
> 
> On Sat, Nov 06, 2004 at 11:08:55PM +1100, Nick Piggin wrote:
> 
>>If they're not racy.
> 
> 
> Only one race matters: contributions to accounting. Reporting is
> inherently racy without stop-the-world -style locking. But the
> contributions to accounting are irrelevant: shared counter partitions
> must be updated atomically, fully-cpu-private partitions can't race
> with each other. So we are done.
> 

Hmm, possibly.. if you make the counters signed and have some
logic to clamp the total to >= 0. But I expect per CPU counters
will be too large for Christoph anyway... and would certainly
not be an option for 2.6 (or any mainline kernel) either.

Anyway we'll see how his tests go.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
