Date: Mon, 9 Oct 2000 21:27:47 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: RE: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <32B7FDA9BF4CE64FB10864F5E4972A031DFAD3@cpt-sas-ex01.corptst.amazon.com>
Message-ID: <Pine.SOL.4.21.0010092125540.7984-100000@green.csi.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Wagner, Dave" <dwagner@amazon.com>
Cc: mingo@elte.hu, Ed Tomlinson <tomlins@cam.org>, Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Wagner, Dave wrote:

> > -----Original Message-----
> > From: Ingo Molnar [mailto:mingo@elte.hu]
> > Sent: Monday, October 09, 2000 11:02 AM
> > To: Ed Tomlinson
> > Cc: Mark Hahn; Marco Colombo; Rik van Riel; linux-mm@kvack.org
> > Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
> > 
> > 
> > On Mon, 9 Oct 2000, Ed Tomlinson wrote:
> > 
> > > What about the AIX way?  When the system is nearly OOM it sends a
> > > SIG_DANGER signal to all processes.  Those that handle the 
> > signal are
> > > not initial targets for OOM...  Also in the SIG_DANGER 
> > processing they
> > > can take there own actions to reduce their memory usage... (we would
> > > have to look out for a SIG_DANGER handler that had a memory leak
> > > though)
> > 
> > i think 'importance' should be an integer value, not just a 
> > 'can it handle
> > SIG_DANGER' flag.
> > 
> In a perfect world, perhaps.  But how many people/systems are going to
> have a well-thought out distribution of "importance" values.  It's
> probably too much to have people even set a single boolean value
> reasonably.

You could say exactly the same about niceness: how many people have a
well-thought out distribution of nice values? Yet the mechanism works
reasonably well: important system things get -ve values, normal user
processes get the default, CPU hogs get niced down a bit.

> How about a bit in the executable to say "unimportant".  Netscape, would
> of course, have this bit set. ;-)

I think an integer, just like nice, would be the way to go.


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
