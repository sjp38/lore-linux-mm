Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B96196B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 13:38:26 -0400 (EDT)
Date: Mon, 19 Apr 2010 12:38:05 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
In-Reply-To: <1271606079.2100.159.camel@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1004191235160.9855@router.home>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>  <4BC65237.5080408@kernel.org>  <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>  <4BC6BE78.1030503@kernel.org>  <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
  <4BC6CB30.7030308@kernel.org>  <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>  <4BC6E581.1000604@kernel.org>  <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>  <4BC6FBC8.9090204@kernel.org>
 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>  <alpine.DEB.2.00.1004161105120.7710@router.home> <1271606079.2100.159.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Apr 2010, Minchan Kim wrote:

> My concern is following as.
>
> alloc_pages_node means any node but it has nid argument.
> Why should user of alloc_pages who want to get page from any node pass
> nid argument? It's rather awkward.

Its not awkward but an optimization. The page can be placed on any node
but the user would prefer a certain node. Most of the NUMA things are
there for optimization purposes and not for correctness. If you must have
an allocation on certain nodes for correctness (like SLAB) then
GFP_THISNODE is used.

> Some of user misunderstood it and used alloc_pages_node instead of
> alloc_pages_exact_node although he already know exact _NID_.
> Of course, it's not a BUG since if nid >= 0 it works well.
>
> But I want to remove such multiple meaning to clear intention of user.

Its not clear to me that this renaming etc helps. You
must use GFP_THISNODE if allocation must occur from a certain node.
alloc_pages_exact_node results in more confusion because it does suggest
that fallback to other nodes is not allowed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
