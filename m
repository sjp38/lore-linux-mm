Date: Thu, 27 Dec 2007 12:59:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <47741156.4060500@hp.com>
Message-ID: <Pine.LNX.4.64.0712271258340.533@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
 <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com>
 <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com>
 <477403A6.6070208@hp.com> <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com>
 <47741156.4060500@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007, Mark Seger wrote:

> ok, here's a dumb question...  I've been looking at slabinfo and see a routine
> called find_one_alias which returns the alias that gets printed with the -f
> switch.  the only thing is the leading comment says "Find the shortest alias
> of a slab" but it looks like it returns the longest name.  Did you change the
> functionality after your wrote the comment?  that'll teach you for commenting
> your code!  8-)

Yuck.

> I'm also not sure why it would stop the search when it finds an alias that
> started with 'kmall'.  Is there some reason you wouldn't want to use any of
> those names as potential candidates?  Does it really matter how I choose the
> 'first' name?  It's certainly easy enough to pick the longest, I'm just not
> sure about the test for 'kmall'.

Well the kmallocs are generic and just give size information. You want a 
slab name that is more informative than that. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
