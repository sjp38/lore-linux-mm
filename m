Date: Thu, 31 Jul 2003 11:43:17 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: do_wp_page 
In-Reply-To: <Pine.LNX.4.53.0307311131040.5476@skynet>
Message-ID: <Pine.LNX.4.53.0307311142270.5476@skynet>
References: <Pine.GSO.4.51.0307301514240.8932@aria.ncl.cs.columbia.edu>
 <Pine.LNX.4.53.0307311131040.5476@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2003, Mel Gorman wrote:

> the only one that can be mapped into a process with that bit set. If you
> look at do_no_page()

bah, that should be do_anonymous_page()

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
