Message-ID: <3D2C9972.BB3DA772@opersys.com>
Date: Wed, 10 Jul 2002 16:30:42 -0400
From: Karim Yaghmour <karim@opersys.com>
Reply-To: karim@opersys.com
MIME-Version: 1.0
Subject: Re: Enhanced profiling support (was Re: vm lock contention reduction)
References: <OFF41DACAC.FEED90BA-ON80256BF2.004DC147@portsmouth.uk.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard J Moore <richardj_moore@uk.ibm.com>
Cc: John Levon <movement@marcelothewonderpenguin.com>, Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, bob <bob@watson.ibm.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, mjbligh@linux.ibm.com, John Levon <moz@compsoc.man.ac.uk>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Richard J Moore wrote:
> Some level of tracing (along with other complementary PD tools e.g. crash
> dump) needs to be readiliy available to deal with those types of problem we
> see with mature systems employed in the production environment. Typically
> such problems are not readily recreatable nor even prictable. I've often
> had to solve problems which impact a business environment severely, where
> one server out of 2000 gets hit each day, but its a different one each day.
> Its under those circumstances that trace along without other automated data
> capturing problem determination tools become invaluable. And its a fact of
> life that only those types of difficult problem remain once we've beaten a
> system to death in developments and test. Being able to use a common set of
> tools whatever the componets under investigation greatly eases problem
> determination. This is especially so where you have the ability to use
> dprobes with LTT to provide ad hoc tracepoints that were not originally
> included by the developers.

I definitely agree.

One case which perfectly illustrates how extreme these situations can be is
the Mars Pathfinder. The folks at the Jet Propulsion Lab used a tracing tool
very similar to LTT to locate the priority inversion problem the Pathfinder
had while it was on Mars.

The full account gives an interesting read (sorry for the link being on
MS's website but its author works for MS research ...):
http://research.microsoft.com/research/os/mbj/Mars_Pathfinder/Authoritative_Account.html

Karim

===================================================
                 Karim Yaghmour
               karim@opersys.com
      Embedded and Real-Time Linux Expert
===================================================
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
