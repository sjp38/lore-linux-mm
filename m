Date: Wed, 2 Jul 2003 14:10:55 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: [RFC] My research agenda for 2.7
Message-ID: <20030702211055.GC13296@matchmail.com>
References: <200306250111.01498.phillips@arcor.de> <200306262100.40707.phillips@arcor.de> <Pine.LNX.4.53.0306262030500.5910@skynet> <200306270222.27727.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0306271345330.14677@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Daniel Phillips <phillips@arcor.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 27, 2003 at 02:00:42PM +0100, Mel Gorman wrote:
> You're right, I will need to write a proper RFC one way or the other. I
> was thinking of using slabs because that way there wouldn't be need to
> scan all of mem_map, just a small number of slabs. I have no basis for
> this other than hand waving gestures though.

Mel,

This sounds much like something I was reading from Larry McVoy using page
objects (like one level higher in magnatude than pages).

I don't remember the URL, but there was something pretty extensive from
Larry already explaining the concept.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
