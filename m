Date: Mon, 28 Oct 2002 10:53:43 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.44-mm6
In-Reply-To: <3DBCD3D3.8DDA3982@digeo.com>
Message-ID: <Pine.LNX.4.44L.0210281051440.1697-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Oct 2002, Andrew Morton wrote:

> . Spent some time tuning up 2.5's StupidSwapStorm throughput.  It's
>   on par with 2.4 for single-threaded things, but not for multiple
>   processes.
>
>   This is because 2.4's virtual scan allows individual processes to
>   hammer all the others into swap and to make lots of progress then
>   exit.  In the 2.5 VM all processes make equal progress and just
>   thrash each other to bits.
>
>   This is an innate useful side-effect of the virtual scan, although
>   it may have significant failure modes.  The 2.5 VM would need an
>   explicit load control algorithm if we care about such workloads.

1) 2.4 does have the failure modes you talk about ;)

2) I have most of an explicit load control algorithm ready,
   against an early 2.4 kernel, but porting it should be very
   little work

Just let me know if you're interested in my load control mechanism
and I'll send it to you.  Note that I never got the load control
_policy_ right yet ...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
