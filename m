Date: Thu, 10 Apr 2003 14:02:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <20030410210211.GI1828@holomorphy.com>
References: <20030410122421.A17889@lst.de> <20030410095930.D9136@redhat.com> <20030410134334.37c86863.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030410134334.37c86863.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 10, 2003 at 01:43:34PM -0700, Andrew Morton wrote:
> Agreed.  I've updated the patch thusly.
> Bootmem igornamus says:
> Do we have a problem with using an `unsigned long' byte address in there on
> ia32 PAE?  Or are we guaranteed that this will only ever be used in the lower
> 4G of physical memory?

It's only ever used for lowmem on ia32, which is even below 1GB.


On Thu, Apr 10, 2003 at 01:43:34PM -0700, Andrew Morton wrote:
> Does the last_success cache ever need to be updated if someone frees some
> previously-allocated memory?

Setting preferred only puts a finger on where to begin a search. The
search (and validity checking) are still carried out as usual. It could
be suboptimal to set it to somewhere that's not as good as possible
after a free, but it's only advice as to where to start a search and so
doesn't affect correctness so long as it's in-bounds.

I'm just going to grab a barfbag and run now.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
