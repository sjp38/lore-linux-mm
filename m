Date: Mon, 25 Jun 2001 21:53:33 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning through fault trace gathering [with actual code]
In-Reply-To: <m2d77s4m34.fsf@boreas.yi.org.>
Message-ID: <Pine.LNX.4.21.0106252152580.941-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@users.sourceforge.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On 25 Jun 2001, John Fremlin wrote:

> 
> Last year I had the idea of tracing the memory accesses of the system
> to improve the VM - the traces could be used to test algorithms in
> userspace. The difficulty is of course making all memory accesses
> fault without destroying system performance.
> 
> The following patch (i386 only) will dump all page faults to
> /dev/biglog (you need devfs for this node to appear). If you echo 1 >
> /proc/sys/vm/trace then *almost all* userspace memory accesses will
> take a soft fault. Note that this is a bit suicidal at the moment
> because of the staggeringly inefficient way its implemented, on my box
> (K6-2 300MHz) only processes which do very little (e.g. /usr/bin/yes)
> running at highest priority are able to print anything to the console.
> 
> I think the best way would be to have only one valid l2 pte per
> process. I'll have a go at doing that in a day or two unless someone
> has a better idea?

Linux Trace Toolkit (http://www.opersys.com/LTT) does that. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
