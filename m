Date: Thu, 27 Dec 2007 11:53:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <47740228.2010508@hp.com>
Message-ID: <Pine.LNX.4.64.0712271152230.30817@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
 <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com>
 <Pine.LNX.4.64.0712271137470.30555@schroedinger.engr.sgi.com>
 <47740228.2010508@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007, Mark Seger wrote:

> > Order = 0. So Total would be 4096 << 0 = 4096. Wrong value.
> >   
> I'm not sure what your 'wong value.  I think it's because I said page_size <<
> order instead of (page_size << order ) * number of slabs, right?

Right.

> one more thing - can I assume order is a constant for a particular type of a
> slab and only need to read it at initialization time?

Correct. Only the number of slabs and the number of objects changes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
