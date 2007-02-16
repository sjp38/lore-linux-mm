Date: Thu, 15 Feb 2007 18:34:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070215174957.f1fb8711.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Andrew Morton wrote:

> Guys, this page-flag problem is really serious.  -mm adds PG_mlocked and
> PG_readahead and the ext4 patches add PG_booked (am currently fighting the
> good fight there).  There's ongoing steady growth in these things and soon
> we're going to be in a lot of pain.

Well is it possible to restrict some of the features to 64 bit only? There 
we have lots of page flags.

One additional measure that may be possible is to have a page type field
(maybe 3 bits long) that would consolidate a series of page flags that 
cannot occur together. But then we have issues with the atomicity of 
updates to that field.

F.e.

page_type = { SLAB, LRU, MLOCK, RESERVED, BUDDY, <add 3 more types here> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
