Date: Fri, 8 Jun 2001 17:44:32 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.31.0106081439540.7448-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0106081743070.2699-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 8 Jun 2001, Linus Torvalds wrote:

> 
> 
> On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
> >
> > How do you think the problem should be attacked, if you have any opinion
> > at all ?
> 
> Let's try the "refill_inactive() also does VM scanning" approach, as that
> should make sure that we are never in the situation that we haven't taken
> the virtually mapped pages sufficiently into account for aging.

I've tried that in the past, and the behaviour I got was pages being
swapped out with little (or not any) VM pressure. 

Yes, we want fair aging. No, we dont want more pages being swapped out. 

Well, I'll take a look at this. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
