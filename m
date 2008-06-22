Date: Sat, 21 Jun 2008 21:13:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
In-Reply-To: <20080622013801.GE4692@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0806212107510.18908@schroedinger.engr.sgi.com>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
 <20080621224135.GD4692@csn.ul.ie> <Pine.LNX.4.64.0806211711470.18719@schroedinger.engr.sgi.com>
 <20080622013801.GE4692@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexander Beregalov <a.beregalov@gmail.com>, kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Jun 2008, Mel Gorman wrote:

> > Before the change we walk all zones of the zonelist.
> > 
> 
> Yeah, but the zonelist is for GFP_KERNEL so it should not include the HIGHMEM
> zones, right? The key change is that after the patch there are fewer zonelists
> than get filtered.

But the HIGHMEM zones etc were included before. There was no check for 
HIGHMEM etc there. The gfpmask was ignored.
 
> I think the effect of that patch is that zones get shrunk that have
> nothing to do with the requestors requirements. Right?

Right. AFAICT That was the behavior before the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
