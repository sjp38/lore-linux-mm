Date: Sun, 20 May 2001 19:38:59 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <20010520173252.Q754@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.33.0105201740570.1377-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2001, Ingo Oeser wrote:

> On Sun, May 20, 2001 at 05:29:49AM +0200, Mike Galbraith wrote:
> > I'm not sure why that helps.  I didn't put it in as a trick or
> > anything though.  I put it in because it didn't seem like a
> > good idea to ever have more cleaned pages than free pages at a
> > time when we're yammering for help.. so I did that and it helped.
>
> The rationale for this is easy: free pages is wasted memory,
> clean pages is hot, clean cache. The best state a cache can be in.

Sure.  Under low load, cache is great.  Under stress, keeping it is
not an option though ;-)  We're at or beyond capacity and moving at
a high delda V (people yammering for help).  If you can recognize and
kill the delta rapidly by dumping that which you are going to have
to dump anyway, you save time getting back on your feet.  (my guess
as to why dumping clean pages does measurably help in this case)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
