Message-ID: <3D3B925D.624986EE@zip.com.au>
Date: Sun, 21 Jul 2002 22:04:29 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
References: <Pine.LNX.4.44L.0207201740580.12241-100000@imladris.surriel.com> <Pine.LNX.4.44.0207201351160.1552-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Sat, 20 Jul 2002, Rik van Riel wrote:
> >
> > OK, I'll try to forward-port Ed's code to do that from 2.4 to 2.5
> > this weekend...
> 
> Side note: while I absolutely think that is the right thing to do, that's
> also the much more "interesting" change. As a result, I'd be happier if it
> went through channels (ie probably Andrew) and had some wider testing
> first at least in the form of a CFT on linux-kernel.
> 

I'd suggest that we avoid putting any additional changes into
the VM until we have solutions available for:

2: Make it work with pte-highmem  (Bill Irwin is signed up for this)

4: Move the pte_chains into highmem too (Bill, I guess)

6: maybe GC the pte_chain backing pages. (Seems unavoidable.  Rik?)


Especially pte_chains in highmem.  Failure to fix this well
is a showstopper for rmap on large ia32 machines, which makes
it a showstopper full stop.

If we can get something in place which works acceptably on Martin
Bligh's machines, and we can see that the gains of rmap (whatever
they are ;)) are worth the as-yet uncoded pains then let's move on.
But until then, adding new stuff to the VM just makes a `patch -R'
harder to do.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
