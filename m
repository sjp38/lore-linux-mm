Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD86D6B01F9
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:42:12 -0400 (EDT)
Date: Thu, 15 Apr 2010 19:41:28 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004151939310.17800@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>  <20100413083855.GS25756@csn.ul.ie> <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010, Bob Liu wrote:

> If move to the next node instead of early return, the relative position of the
> page to the beginning of the node set will be break;

Right.

> (BTW:I am still not very clear about the preservation of the relative
> position of the
> page to the beginning of the node set. I think if the user call
> migrate_pages() with
> different count of src and dest nodes, the  relative position will also break.
> eg. if call migrate_pags() from nodes is node(1,2,3) , dest nodes is
> just node(3).
> the current code logical will move pages in node 1, 2 to node 3. this case the
> relative position is breaked).

But in that case the user has specified that the set of nodes should be
compacted during migration and therefore requested what ocurred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
