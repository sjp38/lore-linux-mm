Subject: Re: pre2 swap_out() changes
References: <Pine.LNX.4.10.10101121138060.2249-100000@penguin.transmeta.com>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 13 Jan 2001 12:51:15 +0100
In-Reply-To: Linus Torvalds's message of "Fri, 12 Jan 2001 11:45:26 -0800 (PST)"
Message-ID: <87y9wffz64.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On 12 Jan 2001, Zlatko Calusic wrote:
> > 
> > Performance of 2.4.0-pre2 is terrible as it is now. There is a big
> > performance drop from 2.4.0. Simple test (that is not excessively
> > swapping, I remind) shows this:
> > 
> > 2.2.17     -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
> > 2.4.0      -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
> > 2.4.0-pre2 -> make -j32  393.32s user 138.20s system 129% cpu 6:51.82 total
> 
> Marcelo's patch (which is basically the pre2 mm changes - the other was
> the syntactic change of making "swap_cnt" be an argument to swap_out_mm()
> rather than being a per-mm thing) will improve feel for stuff that doesn't
> want to swap out - VM scanning is basically handled exclusively by kswapd,
> and it only triggers under low-mem circumstances.
> 

Hm, what I noticed is completely the opposite. pre2 seems a little bit
reluctant to swap out, and when it does it looks like it picks wrong
pages. During the compile sessions (results above) pre2 had long
periods where it just tried to get its working set in memory and
during that time all 32 processes were on hold. Thus only 129% CPU
usage and much longer total time.

On the other hand, 2.4.0 + Marcelo kept both processors busy at all
times. Sometimes only few processes were TASK_RUNNING, but the system
_never_ got in the situation where it had spare unused CPU cycles.

If I start typical make -j2 compile my %CPU time is also 182% or 183%,
so 2.4.0 was _really_ good.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
