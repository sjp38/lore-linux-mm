Message-ID: <3911BF09.653D9A2@sgi.com>
Date: Thu, 04 May 2000 11:18:49 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.21.0005041438360.23740-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> > Linus Torvalds wrote:
> 
> > > There might be other details like this lurking, but this looks like a good
> > > first try. Ananth, willing to give it a whirl?
> >
> > I haven't looked at the code, but I replaced the whole while (1)
> > loop with the new for(;;). Things still remain the same: when
> > running dbench VM starts killing processes.
> 
> I've been thinking about it some more. When we look
> carefully the killing is always accompanied by a sudden
> decrease in free memory (while kswapd could easily keep
> up a few seconds ago).

You may have something here. It's the burstiness of
the demand. One thing I haven't noticed here in linux-mm
is any approaches to throttle the demand (Or may be I haven't
looked enough). Why not keep requests for new pages unsatisfied
if the _rate_ of allocations exceeds the _rate_ of freeing
(through swap-out or through write-out [bdflush])?

Simple counters don't capture rates. We need deltas in
the last 'n' time intervals. Then, match the delta-A
(allocation) to delta-F (free). 

Just a thought,

ananth.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
