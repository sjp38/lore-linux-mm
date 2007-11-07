Date: Tue, 6 Nov 2007 19:02:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
In-Reply-To: <20071106215552.4ab7df81@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061856400.5565@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <20071103185516.24832ab0@bree.surriel.com> <Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
 <20071106215552.4ab7df81@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, Rik van Riel wrote:

> > I think we could add a flag to the bdi to indicate wheter the backing 
> > store is a disk file. In fact you can also deduce if if a device has
> > no writeback capability set in the BDI.
> > 
> > > Unfortunately this needs to use a page flag, since the
> > > PG_swapbacked state needs to be preserved all the way
> > > to the point where the page is last removed from the
> > > LRU.  Trying to derive the status from other info in
> > > the page resulted in wrong VM statistics in earlier
> > > split VM patchsets.
> > 
> > The bdi may avoid that extra flag.
> 
> The bdi will no longer be accessible by the time a page
> makes it to free_hot_cold_page, which is one place in the
> kernel where this information is needed.

At that point you need only information about which list the page
was put on. Dont we need something like PageLRU -> PageFileLRU
and PageMemLRU?

The page may change its nature I think? What if a page becomes
swap backed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
