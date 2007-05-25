Date: Fri, 25 May 2007 11:56:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/6] Compound Page Enhancements
In-Reply-To: <20070525101411.a95bd2ea.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705251153410.7281@schroedinger.engr.sgi.com>
References: <20070525051716.030494061@sgi.com> <20070524230032.554be39e.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705250701400.5490@schroedinger.engr.sgi.com>
 <20070525101411.a95bd2ea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Andrew Morton wrote:

> > But then PageHead(page) wont work anymore. pagehead->first_page is in use 
> > for some other purpose.
> 
> That's only because slub came along and screwed it all up.  The compound
> page management used to be consistent, and simple.

Yeah I tried to keep it that way. Had to mess it up with the strange bit 
checks to get it in.

> Specifically: that lockless_freelist afterthought rendered us unable to fix
> this mess.

The main mess of page->private not being usable was fixed up. Now this can 
be even cleaner if we had PageTail and PageHead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
