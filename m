Date: Wed, 10 Jul 2002 15:22:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020710222210.GU25360@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D2C9288.51BBE4EB@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
[11 other things]
>> (12) the reverse mappings enable proper RSS limit enforcement
>>         implemented and merged in 2.4-based rmap

On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> Score one.

Phenomenally harsh.


On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> c'mon, guys.  It's all fluff.  We *have* to do better than this.
> It's just software, and this is just engineering.  There's no
> way we should be asking Linus to risk changing his VM based on
> this sort of advocacy.

I did not give detailed results, but there is quantitative measurement
to back up claims that several of these improve performance. Part of
this "flop" is that the criteria are unclear, and another is my fault
for not benchmarking as much as I should.

What I gave was meant to be of this form, namely "algorithmic
improvement X" and "feature enablement Y". But this is clearly
not what you're after.


On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> Bill, please throw away your list and come up with a new one.
> Consisting of workloads and tests which we can run to evaluate
> and optimise page replacement algorithms.

Your criteria are quantitative. I can't immediately measure all
of them but can go about collecting missing data immediately and post
as I go, then. Perhaps I'll even have helpers. =)


On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> Alternatively, please try to enumerate the `operating regions'
> for the page replacement code.  Then, we can identify measurable
> tests which exercise them.  Then we can identify combinations of
> those tests to model a `workload'.    We need to get this ball
> rolling somehow.
> btw, I told Rik I'd start on that definition today, but I'm having
> trouble getting started.  Your insight would be muchly appreciated.

Excellent. I'll not waste any more time discussing these kinds of
benefits and focus on the ones considered relevant by maintainers.

I've already gone about asking for help benchmarking dmc's pte_chain
space optimization, and I envision the following list of TODO items
being things you're more interested in:

(1) measure the effect of rmap on page fault rate
(1.5) try to figure out how many of mainline's faults came from the
	virtual scan unmapping things
(2) measure the effect of rmap on scan rate
(3) measure the effect of rmap on cpu time consumed by scanning
(4) measure the effect of per-zone LRU lists on cpu time consumed by
	scanning
(5) measure the effect of per-zone LRU list locks on benchmarks
(6) maybe hack a simulator to compare the hardware referenced bits
	to the software one computed by rmap and mainline
(7) re-do(?) swap accuracy measurements in a more meaningful way

(5) may involve some pain to forward port and (6) is painful too.
And these involve writing lots of instrumentation code...

What other missing data are you after and which of these should
be chucked?

As far as operating regions for page replacement go I see 3 obvious ones:
(1) lots of writeback with no swap
(2) churning clean pages with no swap
(3) swapping

And each of these with several proportions of memory sharing.
Sound reasonable?


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
