Message-ID: <39628664.7756172A@norran.net>
Date: Wed, 05 Jul 2000 02:50:45 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] latency improvements, one reschedule moved
References: <395D520C.F16DD7D6@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

Hi Linus,

Cleaned up and corrected some bugs...
(memory_pressure... !
 unintended reschedule removed)

Sadly the performance went down - slightly.
Latency looks even nicer. Still some spikes.
[sync and mmap002 behaviour not corrected]

/RogerL



Roger Larsson wrote:
> 
> Hi Linus,
> 
> [patch against  linux-2.4.0-test3-pre2]
> 
> I cleaned up kswapd and moved its reschedule point.
> Disk performance is close to the same.
> Latencies have improved a lot (tested with Bennos latencytest)
> 
> * sync is still problematic
> * mmap002 (Quintinela) still gives a 212 ms latency
>   (compared to 423 ms for the unpatched...)
> * other disk related latencies are down under 30 ms.
>   (streaming read, copy, write)
> * the number of overruns has dropped considerably!
>   (running 4 buffers with a deadline of 23 ms)
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
>                                               Name: patch-2.4.0-test3-pre2-vmscan.latency.2
>    patch-2.4.0-test3-pre2-vmscan.latency.2    Type: Plain Text (text/plain)
>                                           Encoding: 7bit

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
