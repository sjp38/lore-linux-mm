Date: Thu, 18 Nov 2004 18:35:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: another approach to rss : sloppy rss
In-Reply-To: <419D4EC7.6020100@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com>
 <419D4EC7.6020100@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2004, Nick Piggin wrote:

> What do you think a per-mm flag to switch between realtime and lazy rss?

Yes thats what the patch has.

> The only code it would really _add_ would be your mm counting function...
> I guess another couple of branches in the fault handlers too, but I don't
> know if they'd be very significant.

You would need to add hooks to all uses of rss. That adds additional code
to the critical paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
