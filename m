Date: Thu, 18 Nov 2004 17:14:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: another approach to rss : sloppy rss
In-Reply-To: <419D47E6.8010409@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <419D47E6.8010409@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2004, Nick Piggin wrote:

> > The patch insures that negative rss values are not displayed and removes 3
> > checks in mm/rmap.c that utilized rss (unecessarily AFAIK).
> I wonder if your lazy rss counting still has a place? You still have
> a shared cacheline with sloppy rss. But is it significantly better
> for you just by using unlocked instructions...

Right. The fetchadd for atomic increments really bites here.

Got an enhanced lazy rss patch here but it got so much opposition and then
I discovered that one of our other projects here at SGI depends on
realtime rss.

>     4   3    4    0.180s     16.271s   5.010s 47801.151 154059.862
>
> ... can you tell me what these numbers mean?

Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec

But that was not relevant to this thread. I should have left that out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
