Message-ID: <39E21CCB.61AC1EBE@kalifornia.com>
Date: Mon, 09 Oct 2000 12:30:20 -0700
From: David Ford <david@kalifornia.com>
Reply-To: david+validemail@kalifornia.com
MIME-Version: 1.0
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
References: <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Then spam the console loudly with printk, but don't destroy the whole machine.
Init should only get killed if it REALLY is taking a lot of memory.  On a 4 or 8meg
machine tho, the probability of init getting killed is simply too high for
comfort.  I have never ever seen init start consuming memory like this so I'd
rather get spammed on the console a LOT then have my entire machine instantly go
dead.

We get enough reports about innocuous messages on the console, I'm sure these would
get reported to LKML as well...and in short order as is usual.

-d

Ingo Molnar wrote:

> On Mon, 9 Oct 2000, Andrea Arcangeli wrote:
>
> > On Fri, Oct 06, 2000 at 04:19:55PM -0400, Byron Stanoszek wrote:
> > > In the OOM killer, shouldn't there be a check for PID 1 just to enforce that
> >
> > Init can't be killed in 2.2.x latest, the same bugfix should be forward
> > ported to 2.4.x.
>
> I believe we should not special-case init in this case. If the OOM would
> kill init then we *want* to know about it ASAP, because it's either a bug
> in the OOM code or a memory leak in init. Both things are very bad, and
> ignoring the kill would just preserve those bugs artificially.

--
      "There is a natural aristocracy among men. The grounds of this are
      virtue and talents", Thomas Jefferson [1742-1826], 3rd US President



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
