Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA16151
	for <linux-mm@kvack.org>; Thu, 20 Nov 1997 08:14:28 -0500
Date: Thu, 20 Nov 1997 10:00:52 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: vhand-2.1.64... problems solved - but not all ;)
In-Reply-To: <64vsjf$aq@pccross.average.org>
Message-ID: <Pine.LNX.3.91.971120095338.11037A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eugene Crosser <crosser@average.org>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 19 Nov 1997, Eugene Crosser wrote:

> just to let you know.  For me, all 2.1.xx kernels are hanging trying
> to allocate TCP buffers (I reported this problem), and I tried vhand
> patch in the hope that it may help, as it deals with memory management.

It's still in beta :)
> 
> Unfortunately, it did not.  I got the system hung with the same
> symptoms in less then 24 hours uptime.  Also, perfomance of cpu
> intensive applications (mpg123) dropped noticably with vhand.

I'm working on that one, and it seems like Joe Fouch has given
me the 'golden hint' on what to do. So I implemented his idea
and tested... It improved performance in CPU intensive applications,
but I/O intensive stuff really suffers.
In vhand-2.1.66 this should be better...
> 
> I have a 120MHz 486dx4 w/16Mb, kernel 2.1.63+vhand-2.1.63.
> 
> BTW, Zlatko's patch seemed to cure the hang problem, but after a few
> days, the system freezed anyway at the same place.

Hmmm, could you give me some more details:
- type of network card
- amount of network-buffers allocated each second (!)
- size of allocated network buffers
- amount of swapping/paging going on
- how was the CPU usage of kswapd/vhand during that time?

thanks and good luck,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
