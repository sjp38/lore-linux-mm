Subject: Re: [RFC][PATCH] IO wait accounting
References: <Pine.LNX.4.44L.0205121812500.32261-100000@imladris.surriel.com>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: Mon, 13 May 2002 13:45:54 +0200
In-Reply-To: <Pine.LNX.4.44L.0205121812500.32261-100000@imladris.surriel.com> (Rik
 van Riel's message of "Sun, 12 May 2002 18:14:01 -0300 (BRT)")
Message-ID: <dnvg9sfez1.fsf@magla.zg.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Bill Davidsen <davidsen@tmr.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On Sun, 12 May 2002, Zlatko Calusic wrote:
>> Rik van Riel <riel@conectiva.com.br> writes:
>> >
>> > And should we measure read() waits as well as page faults or
>> > just page faults ?
>>
>> Definitely both.
>
> OK, I'll look at a way to implement these stats so that
> every IO wait counts as iowait time ... preferably in a
> way that doesn't touch the code in too many places ;)
>
>> Somewhere on the web was a nice document explaining
>> how Solaris measures iowait%, I read it few years ago and it was a
>> great stuff (quite nice explanation).
>>
>> I'll try to find it, as it could be helpful.
>
> Please, it would be useful to get our info compatible with
> theirs so sysadmins can read their statistics the same on
> both systems.
>

Yes, that would be nice. Anyway, finding the document I mentioned will
be much harder than I thought. Googling last 15 minutes didn't make
progress. But, I'll keep trying.

Anyway, here is how Aix defines it:

 Average percentage of CPU time that the CPUs were idle during which
 the system had an outstanding disk I/O request. This value may be
 inflated if the actual number of I/O requesting threads is less than
 the number of idling processors.

(http://support.bull.de/download/redbooks/Performance/OptimizingYourSystemPerformance.pdf)

Also, Sun has a nice collection of articles at
http://www.sun.com/sun-on-net/itworld/, and among them
http://www.sun.com/sun-on-net/itworld/UIR981001perf.html which speaks
about wait time, but I'm still searching for a more technical document...
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
