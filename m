Date: Thu, 24 Apr 2003 16:24:56 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.68-mm2
In-Reply-To: <20030423233652.C9036@redhat.com>
Message-ID: <Pine.LNX.3.96.1030424162101.11351C-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2003, Benjamin LaHaise wrote:

> Actually, Ingo's rmap style sounds very similar to what I first implemented 
> in one of my stabs at rmap.  It has a nasty side effect of being worst case 
> for cache organisation -- the sister page tends to map to the exact same 
> cache line in some processors.  Whoops.  That said, I think that the rmap 
> pte-chains can really stand a bit of optimization by means of discarding a 
> couple of bits, as well as merging for adjacent pages, so I don't think 
> the overhead is a lost cause yet.  And nobody has written the clone() patch 
> for bash yet...

I'm not sure the best solution is to try to hack applications doing things
in the way they find best. I suspect that we have to change the kernel so
it handles the requests in a reasonable way.

Of course reasonable way may mean that bash does some things a bit slower,
but given that the whole thing works well in most cases anyway, I think
the kernel handling the situation is preferable.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
