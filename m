Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.21.0005081442030.20790-100000@duckman.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 08 May 2000 20:16:04 +0200
In-Reply-To: Rik van Riel's message of "Mon, 8 May 2000 14:43:38 -0300 (BRST)"
Message-ID: <dnln1kykkb.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 8 May 2000, Zlatko Calusic wrote:
> 
> > BTW, this patch mostly *removes* cruft recently added, and
> > returns to the known state of operation.
> 
> Which doesn't work.
> 
> Think of a 1GB machine which has a 16MB DMA zone,
> a 950MB normal zone and a very small HIGHMEM zone.
> 
> With the old VM code the HIGHMEM zone would be
> swapping like mad while the other two zones are
> idle.
> 
> It's Not That Kind Of Party(tm)
> 

OK, I see now what you have in mind, and I'll try to test it when I
get home (yes, late worker... my only connection to the Net :))
If only I could buy 1GB to test in the real setup. ;)

But still, optimizing for 1GB, while at the same time completely
killing performances even *usability* for the 99% of users doesn't
look like a good solution, does it?

There was lot of VM changes recently (>100K of patches) where we went
further and further away from the mostly stable code base (IMHO)
trying to fix zone balancing. Maybe it's time we try again, fresh from
the "start"?

I'll admit I didn't understand most of the conversation about zone
balancing recently on linux-mm. And I know it's because I didn't have
much time lately to hack the kernel, unfortunately.

But after few hours spent dealing with the horrible VM that is in the
pre6, I'm not scared anymore. And I think that solution to all our
problems with zone balancing must be very simple. But it's probably
hard to find, so it will need lots of modeling and testing. I don't
think adding few lines here and there all the time will take us
anywhere.

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
