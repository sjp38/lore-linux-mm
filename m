Date: Fri, 13 Jul 2007 11:23:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
In-Reply-To: <20070713104044.0d090c79.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707131116080.22727@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky> <Pine.LNX.4.64.0707131001060.21777@schroedinger.engr.sgi.com>
 <20070713104044.0d090c79.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Andrew Morton wrote:

> It would be nice to see a bit of spirited reviewing from the affected arch
> maintainers and mm people...

That was already done a long time ago. Maybe you do not remember it.

See 
http://marc.info/?l=linux-kernel&m=117556067909158&w=2
http://marc.info/?l=linux-kernel&m=117598342420719&w=2
http://marc.info/?l=linux-kernel&m=117541139915535&w=2
http://marc.info/?l=linux-kernel&m=116556142519461&w=2

> There's already an enormous amount of mm stuff banked up and it looks like
> I get to hold onto a lot of that until 2.6.24.  We seem to be spending too
> little time on the first 90% of new stuff and too little time on the last
> 10% of existing stuff.

Well without this we cannot perform the cleanup of the miscellaneous 
memory models around. The longer this is held up the longer the discontig 
etc will stay in the tree with all the associated #ifdeffery.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
