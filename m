Message-ID: <419D4EC7.6020100@yahoo.com.au>
Date: Fri, 19 Nov 2004 12:39:19 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: another approach to rss : sloppy rss
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 19 Nov 2004, Nick Piggin wrote:
> 
> 
>>>The patch insures that negative rss values are not displayed and removes 3
>>>checks in mm/rmap.c that utilized rss (unecessarily AFAIK).
>>
>>I wonder if your lazy rss counting still has a place? You still have
>>a shared cacheline with sloppy rss. But is it significantly better
>>for you just by using unlocked instructions...
> 
> 
> Right. The fetchadd for atomic increments really bites here.
> 
> Got an enhanced lazy rss patch here but it got so much opposition and then
> I discovered that one of our other projects here at SGI depends on
> realtime rss.
> 

What do you think a per-mm flag to switch between realtime and lazy rss?

The only code it would really _add_ would be your mm counting function...
I guess another couple of branches in the fault handlers too, but I don't
know if they'd be very significant.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
