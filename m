Message-ID: <3D5DA582.A29549F0@zip.com.au>
Date: Fri, 16 Aug 2002 18:23:14 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: clean up mem_map usage ... part 1
References: <3D5D7572.DD7ACA23@zip.com.au> <Pine.LNX.4.44L.0208162131200.1430-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 16 Aug 2002, Andrew Morton wrote:
> 
> > Oh whatever.  If it's in my pile then a few more people get to
> > bang on it for a while.  Looks like a long backlog will become
> > a permanent state, so I'll need to do something more organised
> > there.
> 
> Another reason why I decided to do the page_launder/shrink_cache
> rewrite on 2.4 first.  Once it's stable and the corner cases have
> been ironed out I'll give you something that just works. ;)
> 

I'd like to find a way to improve the stability of the patches
which are being submitted.  I had 1.5 screwups in the latest
batch, and there's the page->pte.chain BUG, and a rather worrisome
batch of BUGs against the latest everything.gz from Badari which
may propagate to 2.5.32.

So I'll go for a more formal off-stream patchset after .32 comes
out - I assume Martin & co will test against that, if only for
the kmap carrot.  We can stage any code you want tested within that.

As things are shown to be stable and worthwhile in that tree I can
pop patches off the bottom and submit them to Linus.

The problem with this rosy picture is that Linus may bounce some of
it back, and all the testing gets invalidated.  So I'll attempt to
get comment from him at a prior-to-submission stage.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
