Date: Fri, 25 May 2001 10:10:18 +0200
From: David Weinehall <tao@acc.umu.se>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
Message-ID: <20010525101018.A473@khan.acc.umu.se>
References: <Pine.LNX.4.33.0105200957500.323-100000@mikeg.weiden.de> <Pine.LNX.4.21.0105200546241.5531-100000@imladris.rielhome.conectiva> <20010520235409.G2647@bug.ucw.cz> <20010521223212.C4934@khan.acc.umu.se> <3B0BF8B6.D7940FA3@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B0BF8B6.D7940FA3@mvista.com>; from scott_anderson@mvista.com on Wed, May 23, 2001 at 05:51:50PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Anderson <scott_anderson@mvista.com>
Cc: Pavel Machek <pavel@suse.cz>, Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2001 at 05:51:50PM +0000, Scott Anderson wrote:
> David Weinehall wrote:
> > IMVHO every developer involved in memory-management (and indeed, any
> > software development; the authors of ntpd comes in mind here) should
> > have a 386 with 4MB of RAM and some 16MB of swap. Nowadays I have the
> > luxury of a 486 with 8MB of RAM and 32MB of swap as a firewall, but it's
> > still a pain to work with.
> 
> If you really want to have fun, remove all swap...

Oh, I've done some testing without swap too, mainly to test Rik's
oom-killer. Seemed to work pretty well. Can't say it was enjoyable, though.


/David
  _                                                                 _
 // David Weinehall <tao@acc.umu.se> /> Northern lights wander      \\
//  Project MCA Linux hacker        //  Dance across the winter sky //
\>  http://www.acc.umu.se/~tao/    </   Full colour fire           </
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
