Subject: Re: [PATCH/RFC 8/14] Reclaim Scalability:  Ram Disk Pages are
	non-reclaimable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46EDDF0F.2080800@redhat.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205451.6536.39585.sendpatchset@localhost>
	 <46EDDF0F.2080800@redhat.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 10:40:39 -0400
Message-Id: <1190040039.5460.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-16 at 21:57 -0400, Rik van Riel wrote:
> Lee Schermerhorn wrote:
> > PATCH/RFC 08/14 Reclaim Scalability:  Ram Disk Pages are non-reclaimable
> > 
> > Against:  2.6.23-rc4-mm1
> > 
> > Christoph Lameter pointed out that ram disk pages also clutter the
> > LRU lists. 
> 
> Agreed, these should be moved out of the way to a nonreclaimable
> list.


Should we also treat ramfs pages the same way?  In your page_anon()
function, which I use in this series, you return '1' for ramfs pages,
indicating that they are swap-backed.  But, this doesn't seem to be the
case.  Looking at the ramfs code, I see that the ramfs
address_space_operations have no writepage op, so pageout() will just
reactivate the page.  You do have a comment/question there about whether
these should be treated as mlocked.  Mel also questions this test in a
later message.

So, I think I should just mark ramfs address space as nonreclaimable,
similar to ram disk.  Do you agree?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
