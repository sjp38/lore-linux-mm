Date: Wed, 10 Jul 2002 21:47:21 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2CD3D3.B43E0E1F@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207102145000.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2002, Andrew Morton wrote:

> A lot of it should be fairly simple.  We have tons of pagecache-intensive
> workloads.  But we have gaps when it comes to the VM.  In the area of
> page replacement.

Umm, page replacement is about identifying the working set
and paging out those pages which are not in the working set.

None of the benchmark examples you give have anything like
a working set.

> Can we fill those gaps with a reasonable amount of effort?

[snip swap & pagecache IO throughput tests]

> After that comes the analysis.  Looks like rmap will be merged in
> the next few days for test-and-eval, so we don't need to go through
> some great beforehand-justification exercise.  But we do need
> a permanent toolkit and we do need a way of optimising the VM.

Absolutely agreed.

> I would suggest that the toolkit consist of two things:
>
> 1: A set of scenarios and associated scripts/tools such as my
>    examples above (except more real-worldy) and
>
> 2: Permanent in-kernel instrumentation which allows us (and
>    remote testers) to understand what is happening in there.

I'm willing to code up number 2 and get it into a mergeable
shape later this week.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
