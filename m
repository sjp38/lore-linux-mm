Date: Wed, 8 Nov 2000 14:53:11 +0100 (CET)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Looking for better VM
In-Reply-To: <Pine.LNX.4.21.0011081052010.1242-100000@fs129-190.f-secure.com>
Message-ID: <Pine.LNX.4.05.10011081450320.3666-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Nov 2000, Szabolcs Szakacsits wrote:
> On Mon, 6 Nov 2000, Rik van Riel wrote:
> > On Mon, 6 Nov 2000, Szabolcs Szakacsits wrote:
> > > On Wed, 1 Nov 2000, Rik van Riel wrote:
> > > > but simply because 
> > > > it appears there has been amazingly little research on this 
> > > > subject and it's completely unknown which approach will work 
> > > There has been lot of research, this is the reason most Unices support
> > > both non-overcommit and overcommit memory handling default to
> > > non-overcommit [think of reliability and high availability].
> > It's a shame you didn't take the trouble to actually
> > go out and see that non-overcommit doesn't solve the
> > "out of memory" deadlock problem.
> 
> Read my *entire* email again and please try to understand. No deadlock
> at all since kernel *falls back* to process killing if memory reserved
> for *root* is also out.
> 
> You could ask, so what's the point for non-overcommit if we use
> process killing in the end? And the answer, in *practise* this almost
> never happens, root can always clean up and no processes are lost
> [just as when disk is "full" except the reserved area for root]. See?
> Human get a chance against hard-wired AI.
> 
> I also didn't say non-overcommit should be used as default and a
> patch http://www.cs.helsinki.fi/linux/linux-kernel/2000-13/1208.html,
> developed for 2.3.99-pre3 by Eduardo Horvath and unfortunately was
> ignored completely, implemented it this way. 

OK. This is a lot more reasonable. I'm actually looking
into putting non-overcommit as a configurable option in
the kernel.

However, this does not save you from the fact that the
system is essentially deadlocked when nothing can get
more memory and nothing goes away. Non-overcommit won't
give you any extra reliability unless your applications
are very well behaved ... in which case you don't need
non-overcommit.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
