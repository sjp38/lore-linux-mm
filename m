Date: Tue, 20 Feb 2007 08:37:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] free swap space when (re)activating page
In-Reply-To: <45DAF794.2000209@redhat.com>
Message-ID: <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com>
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
 <45DAF794.2000209@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Feb 2007, Rik van Riel wrote:

> > It was the portion that modifies shrink_active_list. Why operate
> > on the pagevec there? The pagevec only contains the leftovers to be released
> > from scanning over the temporary inactive list.
> 
> Why?  Because the pages that were not referenced will be
> going onto the inactive list and are now a candidate for
> swapping out.  I don't see why we would want to reclaim
> the swap space for pages that area about to be swapped
> out again.

Sounds sane. Then drop that piece. Again, you were only operating on the 
pages left over in the pagevec after the move of the pages to the 
inactive list. If you really wanted to do something there then the 
processing should have covered all pages that go to the inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
