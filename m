Date: Thu, 31 Jul 2003 19:20:51 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Understanding page faults code in mm/memory.c
In-Reply-To: <Pine.GSO.4.51.0307311308450.8932@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.53.0307311916580.22434@skynet>
References: <20030731111502.GA1591@eugeneteo.net> <Pine.LNX.4.53.0307311242370.10913@skynet>
 <Pine.GSO.4.51.0307311209220.8932@aria.ncl.cs.columbia.edu>
 <Pine.LNX.4.53.0307311805200.22434@skynet> <Pine.GSO.4.51.0307311308450.8932@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: Eugene Teo <eugene.teo@eugeneteo.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2003, Raghu R. Arur wrote:

>
>   No, what i meant was, if the rss value gets decremented when a page is
> put into swap cache, then why is it not incremented in do_wp_page when you
> fault for a page inside swap cache.

Because paging in from the swap cache is handled by do_swap_page() which
does increment rss, not do_wp_page().

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
