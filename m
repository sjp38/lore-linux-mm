Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA3D53> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Thu, 10 Jul 2003 22:58:42 -0700
Date: Thu, 10 Jul 2003 22:44:36 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307110304.11216.phillips@arcor.de>
Message-ID: <Pine.LNX.4.55.0307102238420.3551@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307100059.57398.phillips@arcor.de>
 <16140.51447.73888.717087@wombat.chubb.wattle.id.au> <200307110304.11216.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Peter Chubb <peter@chubb.wattle.id.au>, Jamie Lokier <jamie@shareable.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2003, Daniel Phillips wrote:

> I suspect you are right.  I'd also like to note that this is ground so
> thoroughly trodden that the grass is flat.  Realtime schedulers are a well
> researched topic, it's just too bad that committees don't design them as well
> as engineers would.
>
> Thinking strictly about the needs of sound processing, what's needed is a
> guarantee of so much cpu time each time the timer fires, and a user limit to
> prevent cpu hogging.  It's worth pondering the difference between that and
> rate-of-forward-progress.  I suspect some simple improvements to the current
> scheduler can be made to do the job, and at the same time, avoid the
> priorty-based starvation issue that seems to have been practically mandated
> by POSIX.

I've been finally able to make my sound card to sing with 2.5 and I was
able to sh*t load my machine running RealPlay with the SOFTRR path :

http://www.xmailserver.org/linux-patches/softrr.html

I was not able to get a single skip. For many kind of applications it is
not strong real time that is needed. For example, in case on those
multimedia pps, I saw that they can live pretty happy with 10-20ms
latencies. The problem is that w/out living in the realtime priority even,
they can be sucked in by interactive tasks running they loong timeslice
multiple times. Plus-latencies of 100-150ms are very easy to get. Even if
the average latency, like graphs show, is very close to the expected one.



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
