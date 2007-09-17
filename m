Date: Mon, 17 Sep 2007 11:41:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
In-Reply-To: <1190042245.5460.81.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709171137360.27057@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205438.6536.49500.sendpatchset@localhost>
 <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
 <1190042245.5460.81.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Lee Schermerhorn wrote:

> > One fleeting thought here: It may be useful to *not* allocate known 
> > unreclaimable pages with __GFP_MOVABLE.
> 
> Sorry, I don't understand where you're coming from here.
> Non-reclaimable pages should be migratable, but maybe __GFP_MOVABLE
> means something else?

True. __GFP_MOVABLE + MLOCK is movable. Also the ramfs/shmem pages. There 
may be uses though that require a page to stay put because it is used for 
some nefarious I/O purpose by a driver. RDMA comes to mind. Maybe we need 
some additional option that works like MLOCK but forbids migration. Those 
would then be unreclaimable and not __GFP_MOVABLE. I know some of our 
applications create huge amount of these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
