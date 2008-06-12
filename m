Date: Thu, 12 Jun 2008 13:50:14 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 14/24] Ramfs and Ram Disk pages are unevictable
Message-ID: <20080612135014.026cc2e3@cuia.bos.redhat.com>
In-Reply-To: <200806130337.57118.nickpiggin@yahoo.com.au>
References: <20080611184214.605110868@redhat.com>
	<200806121054.19253.nickpiggin@yahoo.com.au>
	<20080612132952.568226f6@cuia.bos.redhat.com>
	<200806130337.57118.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 03:37:56 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > > This isn't the case for brd any longer. It doesn't use the buffer
> > > cache as its backing store, so the buffer cache is reclaimable.

> > I know that pages of files that got paged into the page
> > cache from the ramdisk can be evicted (back to the ram
> > disk), but how do the brd pages themselves behave?
> 
> They are not reclaimable. But they have nothing (directly) to do
> with brd's i_mapping address space, nor are they put on any LRU
> lists.

Ahhhh, doh!

I'm mailing Andrew a patch right now that undoes the
brd.c part of patch 14/24. The ramdisk part is correct
and should stay (afaict).

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
