Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC][PATCH] alternative way of calculating inactive_target
Date: Thu, 16 Aug 2001 16:06:18 +0200
References: <200108160337.FAA11729@mailb.telia.com> <20010816084939Z16265-1231+1158@humbolt.nl.linux.org> <200108161250.f7GCo8w13004@mailc.telia.com>
In-Reply-To: <200108161250.f7GCo8w13004@mailc.telia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010816135959Z16458-1231+1203@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>, linux-mm@kvack.org
Cc: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
List-ID: <linux-mm.kvack.org>

On August 16, 2001 02:45 pm, Roger Larsson wrote:
> On Thursday den 16 August 2001 10:55, Daniel Phillips wrote:
> > On August 16, 2001 05:33 am, Roger Larsson wrote:
> > BTW, you left out an interesting detail: any performance measurements
> > you've already done.
> 
> I had not done many at that point in time - it was LATE, it did run... 
> etc...
> Now I have some data. (but I had changed a limit too)
> In the tests I have run the difference is nothing consistently better NOR 
> worse.

Oh, hey, I think you need to apply this to the per-zone targets too, that's 
probably why you didn't see anything change.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
