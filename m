Date: Sat, 6 Nov 2004 17:11:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041107011113.GJ2890@holomorphy.com>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au> <20041106103103.GC2890@holomorphy.com> <418CAA44.3090007@yahoo.com.au> <20041106105314.GD2890@holomorphy.com> <418CB06F.1080405@yahoo.com.au> <20041106120624.GE2890@holomorphy.com> <418CBED7.6050609@yahoo.com.au> <20041106122355.GF2890@holomorphy.com> <418D7235.7010501@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418D7235.7010501@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Only one race matters: contributions to accounting. Reporting is
>> inherently racy without stop-the-world -style locking. But the
>> contributions to accounting are irrelevant: shared counter partitions
>> must be updated atomically, fully-cpu-private partitions can't race
>> with each other. So we are done.

On Sun, Nov 07, 2004 at 11:54:13AM +1100, Nick Piggin wrote:
> Hmm, possibly.. if you make the counters signed and have some
> logic to clamp the total to >= 0. But I expect per CPU counters
> will be too large for Christoph anyway... and would certainly
> not be an option for 2.6 (or any mainline kernel) either.
> Anyway we'll see how his tests go.

No, they remain an option and a good one. The space requirements are
not an issue. If Lameter's customers have 10000 cpus they have the RAM
and kernel virtualspace for split counters.

Your purported "tests" have a rather obvious predetermined conclusion.
Some minute amount of overhead for normal machines will be exaggerated
in a supercomputer environment, and all of the detriments will be
carefully hidden by avoiding monitoring processes or monitoring only
low numbers of them.

The proposal, on the other hand, has received more objections since my
own, and from various sources.

Now to brace myself for another of your petty "last word" shenanigans.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
