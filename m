Date: Wed, 21 Aug 2002 19:03:15 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: Re: [PATCH] rmap 14
In-Reply-To: <20020820194142.M2645@redhat.com>
Message-ID: <Pine.LNX.4.44.0208211846130.29496-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2002, Stephen C. Tweedie wrote:

> You can get that by a bit of stats: keeping track of the sum of each
> value you observe plus their squares and cubes gives you the main
> stats you probably want to collect:
>

Good point. My stats analysis is a bit rusty bordering on the non-existant
and so a refresher course is on the way. I aim to start providing stats
analysis tools within the next few versions.  I'm going to focus another
while on data collection before I move heavier onto data analysis.

I've finished the benchmark for anonymous memory referecing for version of
VM Regress 0.6 (released later when I have the docs updated). I've run a
series of tests of 2.4.19 Vs 2.4.19-rmap14a .

http://www.csn.ul.ie/~mel/vmr/2.4.19/smooth_sin_50000/mapanon.html
http://www.csn.ul.ie/~mel/vmr/2.4.19-rmap14a/smooth_sin_50000/mapanon.html

are two of them . It is a test of 5,000,000 page references to a memory
range 50000 pages long, almost twice the size of physical memory.  It
tracks, how long it took to reference a page, the page presense versus
page frequency usage, a graph of vmstat output and the vmstat output
itself. It also shows the parameters of the test, duration of the test,
the kernel version and the output of /proc/cpuinfo and /proc/meminfo.

the only other graph I can think of relevance is one of page age Vs page
presense which would be a lot more useful than page reference count. The
most valuable stats analysis I can think of is against the time reference
data to filter badly skewed data but as I said stats analysis is a bit
away. I'm considering adding oprofile information if it is available.

Is there anything obvious I am missing?

-- 
Mel Gorman
MSc Student, University of Limerick
http://www.csn.ul.ie/~mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
