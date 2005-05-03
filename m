Date: Tue, 3 May 2005 09:16:11 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] how do we move the VM forward? (was Re: [RFC] cleanup of
 use-once)
In-Reply-To: <42771904.7020404@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0505030913480.27756@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0505030037100.27756@chimarrao.boston.redhat.com>
 <42771904.7020404@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.61.0505030913482.27756@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 May 2005, Nick Piggin wrote:

> I think the biggest problem with our twine and duct tape page reclaim
> scheme is that somehow *works* (for some value of works).

> I think we branch a new tree for all interested VM developers to work
> on and try to get performing well. Probably try to restrict it to page
> reclaim and related fundamentals so it stays as small as possible and
> worth testing.

Sounds great.  I'd be willing to maintain a quilt tree for
this - in fact, I've already got a few patches ;)

Also, we should probably keep track of exactly what we're
working towards.  I've put my ideas on a wiki page, feel
free to add yours - probably a new page for stuff that's
not page replacement related ;)

http://wiki.linux-mm.org/wiki/AdvancedPageReplacement

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
