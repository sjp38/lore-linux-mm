Date: Wed, 1 Jan 2003 21:25:04 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.53-mm2
Message-ID: <20030102052504.GQ9704@holomorphy.com>
References: <3E0E4744.8EE126ED@digeo.com> <20030102045327.GC7644@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030102045327.GC7644@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 28, 2002 at 04:52:20PM -0800, Andrew Morton wrote:
>> wli-11_pgd_ctor.patch

On Wed, Jan 01, 2003 at 08:53:27PM -0800, William Lee Irwin III wrote:
> A moment's reflection on the subject suggests to me it's worthwhile to
> generalize pgd_ctor support so it works (without #ifdefs!) on both PAE
> and non-PAE. This tiny tweak is actually more noticeably beneficial
> on non-PAE systems but only really because pgd_alloc() is more visible;
> the most likely reason it's less visible on PAE is "other overhead".
> It looks particularly nice since it removes more code than it adds.
> Touch tested on NUMA-Q (PAE). OFTC #kn testers testing the non-PAE case.

For those needing more interpretation, this is essentially a reinstatement
of the 2.4.x-style pgd/pmd cache optimization in a leak-free and accounted
(in /proc/slabinfo) manner.

The point of the optimizations is that these initializations are large
cache hits to take in a single shot, and in the PAE case, amount to a
full L1 cache flush as they traverse almost an entire 16K.

No rigorous benchmarking has been done yet.

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
