From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sat, 5 Jul 2003 17:28:12 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307050216.27850.phillips@arcor.de>
In-Reply-To: <200307050216.27850.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307051728.12891.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 05 July 2003 02:16, Daniel Phillips wrote:
> It now tolerates window dragging on this unaccelerated moderately high
> resolution VGA without any sound dropouts.  There are still dropouts while
> scrolling in Mozilla, so it acts much like 2.5.73+Con's patch, as expected.

Update: dropouts still do occur while moving windows, but rarely.  When they 
do occur, they are severe.  A debian dist-upgrade just caused a dropout - and 
another just now, about 3 seconds long.  I feel that tweaking is only going 
to get us so far with this.  The situation re scheduling in 2.5 feels much as 
the vm situation did in 2.3, in other words, we're halfway down a long twisty 
road that ends with something that works, after having tried and failed at 
many flavors of tweaking and tuning.  Ultimately the problem will be solved 
by redesign, and probably not just limited to kernel code.

> I had 2.5.74 freeze up a couple of times yesterday, resulting in a totally
> dead, unpingable system, so now I'm running 2.5.74-mm1 with kgdb and hoping
> to catch one of those beasts in the wild.

Update: this is easily repeatable.  A few quick switches between X and text 
mode triggers the freeze reliably.  On two occasions, I had a lockup while 
just doing an innocent window operation.  It also happens in 2.4, so it isn't 
a 2.5 problem per se.  Is it a pure hardware problem?  It's always easy to 
take that position.  I can only guess at the moment.  Kgdb is no help in 
diagnosing, as the kgdb stub also goes comatose, or at least the serial link 
does.  No lockups have occurred so far when I was not interacting with the 
system via the keyboard or mouse.  Suggestions?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
