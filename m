Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0293C6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:23:33 -0500 (EST)
Date: Wed, 26 Jan 2011 15:23:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110126152302.GT18984@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110126141746.GS18984@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 02:17:46PM +0000, Mel Gorman wrote:
> On Mon, Jan 24, 2011 at 04:00:34PM +0100, Andrea Arcangeli wrote:
> > eOn Mon, Jan 24, 2011 at 11:56:46AM +0800, Shaohua Li wrote:
> > > Hi,
> > > With transparent huge page, min_free_kbytes is set too big.
> > > Before:
> > > Node 0, zone    DMA32
> > >   pages free     1812
> > >         min      1424
> > >         low      1780
> > >         high     2136
> > >         scanned  0
> > >         spanned  519168
> > >         present  511496
> > > 
> > > After:
> > > Node 0, zone    DMA32
> > >   pages free     482708
> > >         min      11178
> > >         low      13972
> > >         high     16767
> > >         scanned  0
> > >         spanned  519168
> > >         present  511496
> > > This caused different performance problems in our test. I wonder why we
> > > set the value so big.
> > 
> > It's to enable Mel's anti-frag that keeps pageblocks with movable and
> > unmovable stuff separated, same as "hugeadm
> > --set-recommended-min_free_kbytes".
> > 
> > Now that I checked, I'm seeing quite too much free memory with only 4G
> > of ram... You can see the difference with a "cp /dev/sda /dev/null" in
> > background interleaving these two commands:
> > 
> 
> What kernel is this and is commit
> [99504748: mm: kswapd: stop high-order balancing when any suitable zone
> is balanced] present in the kernel you are testing?
> 
> I'm having very little luck reproducing your scenario with
> 2.6.38-rc2.

Scratch that, a machine with 4G does reproduce it. The machine I was
trying was 2G. Will dig more.

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
