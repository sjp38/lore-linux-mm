Date: Tue, 8 Aug 2000 00:15:57 -0700
From: David Gould <dg@suse.com>
Subject: Re: RFC: design for new VM
Message-ID: <20000808001557.A13549@archimedes.suse.com>
References: <20000807202640.A12492@archimedes.suse.com> <200008080554.WAA19987@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200008080554.WAA19987@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Mon, Aug 07, 2000 at 10:54:43PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 07, 2000 at 10:54:43PM -0700, Kanoj Sarcar wrote:
> > 
> > Hmmm, the vm discussion and the lack of good documentation on vm systems
> > has sent me back to reread my old "VMS Internals and Data Structures" book,
> 
> I have been stressing the importance of documenting what people do
> under Documentation/vm/*. Thinking I would provide an example, I 
> created two new files there, at least one of which was quickly outdated
> by related changes ...
> 
> It would probably help documentation if Linus asked for that along
> with patches which considerably change current algorithms. Trust me,
> I have had to go back and look at documentations three weeks after
> I submitted a patch ... thats all it takes to forget why something
> was done one way, rather than another ...
> 
> Kanoj

Yes, this would be good. Of course, getting documentation to track programs
is sortof an old and apparently insoluble problem. I like the Extreme
Programming approach a bit, because XP makes it clear that there is _no_
documentation other than the code. Worst case, we are where we are now, best
case, the code is more expressive of intent...

But, I think the lack of documentation meant, was the lack of available
literature on on how this stuff is spozed to work.

-dg

-- 
David Gould                                                 dg@suse.com
SuSE, Inc.,  580 2cd St. #210,  Oakland, CA 94607          510.628.3380
"I sense a disturbance in the source"  -- Alan Cox
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
