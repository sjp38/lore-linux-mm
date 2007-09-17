Date: Mon, 17 Sep 2007 11:14:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <20070916180527.GB15184@skynet.ie>
Message-ID: <Pine.LNX.4.64.0709171113210.26860@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost> <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
 <20070913182344.GB23752@skynet.ie> <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
 <20070913141704.4623ac57.akpm@linux-foundation.org> <20070914085335.GA30407@skynet.ie>
 <1189800926.5315.76.camel@localhost> <20070916180527.GB15184@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 16 Sep 2007, Mel Gorman wrote:

> I wonder why they are slower for the remote allocations. I wonder if what we're
> seeing is due to a longer zonelist that is filtered instead of a customised
> shorter zonelist. By and large though, the differences are small as to not
> be noticed.

Maybe because of the node lookups in the zone? A remote allocation with an 
MPOL_BIND list requires longer traversal of the zone list and a comparison 
of node ids by dereferencing the zone.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
