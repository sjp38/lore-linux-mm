Date: Thu, 8 Feb 2007 13:38:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Christoph Lameter wrote:

> > On return from shrink_page_list(),
> > doesn't shrink_inactive_list() put those pages back on the LRU?
> 
> Yes but it has cleared PageReclaim by then.

Crap. You are right. If the page is still under writeback then 
PageReclaim remains set and end_page_writeback puts the page onn the 
inactive list. 

Could we put the page on the inactive list in shrink_page_list?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
