Date: Mon, 12 Nov 2007 14:17:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6 mm] memcgroup: revert swap_state mods
Message-Id: <20071112141757.13ce67dd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0711120447010.23491@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0711090713300.21663@blonde.wat.veritas.com>
	<20071109182156.7174e92b.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0711120447010.23491@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Nov 2007 04:57:03 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:
> > Could I confirm a change in the logic  ?
> > 
> >  * Before this patch, wrong swapcache charge is added to one who
> >    called try_to_free_page().
> 
> try_to_free_pages?  No, I don't think any wrong charge was made
> there. 
Ah, sorry. I misundestood when it was added to swapcache... 

> It was when reading in swap pages.  The usual way is by
> swapin_readahead, which reads in a cluster of swap pages, which
> are quite likely to belong to different memcgroups, but were all
> charged to the one which is doing the fault on its target page.
> Another way is in swapoff, where they all got charged to whoever
> was doing the swapoff (and the charging in unuse_pte was a no-op).
> 
I see.

> >  * After this patch, anonymous page's charge will drop to 0 when
> >    page_remove_rmap() is called.
> 
> Yes, when its final (usually its only) page_remove_rmap is called.
> 
Thank you for confirmation !

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
