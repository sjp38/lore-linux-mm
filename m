Date: Tue, 20 Feb 2007 10:20:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] free swap space when (re)activating page
In-Reply-To: <45DB25E1.7030504@redhat.com>
Message-ID: <Pine.LNX.4.64.0702201015590.14497@schroedinger.engr.sgi.com>
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
 <45DAF794.2000209@redhat.com> <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com>
 <45DB25E1.7030504@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Feb 2007, Rik van Riel wrote:

> Nono, I try to remove the swap space occupied by pages that
> go back onto the active list.  Regardless of whether they
> were already there, or whether they started out on the
> inactive list.

Ok then do it for all pages that go back not just for those leftover from 
the moving of pages to the inactive list (why would you move those???)

> Stripping the swap space of the pages that are going to
> the inactive list makes less sense IMHO, because those
> pages are candidates for swapping out - meaning those
> should keep the space.

Just trying to figure out what your patch does there and it does not make 
much sense to me so far.

Maybe the hunk does apply in a different location than I thought. If you 
do that in the loop over the pages on active list then it would make 
sense. But in that case you need another piece of it doing the same to the 
pages that are released at the end of shrink_active_list().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
