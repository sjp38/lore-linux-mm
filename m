Date: Fri, 27 Jun 2003 07:38:31 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] My research agenda for 2.7
Message-ID: <23150000.1056724707@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.53.0306271345330.14677@skynet>
References: <200306250111.01498.phillips@arcor.de> <200306262100.40707.phillips@arcor.de><Pine.LNX.4.53.0306262030500.5910@skynet> <200306270222.27727.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> IIRC, Martin J. Bligh had a patch which displayed information about the
> buddy allocator freelist so that will probably be the starting point. From
> there, it should be handy enough to see how intermixed are kernel page
> allocations with user allocations. It might turn out that kernel pages
> tend to be clustered together anyway.

That should be merged now - /proc/buddyinfo. I guess you could do the same
for allocated pages (though it'd be rather heavyweight ;-))

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
