Date: Tue, 29 Oct 2002 07:02:03 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.44-mm6
In-Reply-To: <3DBD7176.BAC2BCD3@digeo.com>
Message-ID: <Pine.LNX.3.96.1021029065944.6113B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Oct 2002, Andrew Morton wrote:

> Rik van Riel wrote:

> > 1) 2.4 does have the failure modes you talk about ;)
> 
> Shock :)  How does one trigger them?
> 
> 
> > 2) I have most of an explicit load control algorithm ready,
> >    against an early 2.4 kernel, but porting it should be very
> >    little work
> > 
> > Just let me know if you're interested in my load control mechanism
> > and I'll send it to you.
> 
> It would be interesting if you could send out what you have.
> 
> It would also be interesting to know if we really care?  The
> machine is already running 10x slower than it would be if it
> had enough memory; perhaps it is just not a region of operation
> for which we're interested in optimising.  (Just being argumentitive
> here ;))

I think there is a need for keeping an overloaded machine in some way
usable, not because anyone is really running it that way, but because the
sysadmin needs a way to determine why a correctly sized machine is
suddenly seeing a high load.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
