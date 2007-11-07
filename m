Date: Wed, 7 Nov 2007 09:35:27 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
Message-ID: <20071107093527.0d312903@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0711061920510.5746@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<20071103185516.24832ab0@bree.surriel.com>
	<Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
	<20071106215552.4ab7df81@bree.surriel.com>
	<Pine.LNX.4.64.0711061856400.5565@schroedinger.engr.sgi.com>
	<20071106221710.3f9b8dd6@bree.surriel.com>
	<Pine.LNX.4.64.0711061920510.5746@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 19:26:33 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:
> n Tue, 6 Nov 2007, Rik van Riel wrote:
> 
> > Every anonymous, tmpfs or shared memory segment page is potentially
> > swap backed. That is the whole point of the PG_swapbacked flag.
> 
> One of the current issues with anonymous pages is the accounting when 
> they become file backed and get dirty.

What are you talking about?

How exactly can an anonymous page ever become file backed?

> There are performance issue with swap writeout

That is one of the reasons everything that is ram/swap backed
goes onto a different set of LRU lists from everything that is
backed by a disk or network filesystem.

> Do ramfs pages count as memory backed?

Since ramfs pages cannot be evicted from memory at all, they
should go into the "noreclaim" page set.

> > A page from a filesystem like ext3 or NFS cannot suddenly turn into
> > a swap backed page.  This page "nature" is not changed during the
> > lifetime of a page.
> 
> Well COW sortof does that but then its a new page.

Exactly.  As far as I know, a page never changes from a file
page into an anonymous page, or the other way around.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
