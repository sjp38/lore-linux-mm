Date: Wed, 27 Oct 2004 22:48:37 +0900 (JST)
Message-Id: <20041027.224837.118287069.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041026122419.GD27014@logos.cnet>
References: <20041026092535.GE24462@logos.cnet>
	<20041026.230110.21315175.taka@valinux.co.jp>
	<20041026122419.GD27014@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi,

> > BTW, I wonder how the migration code avoid to choose some pages
> > on LRU, which may have count == 0. This may happen the pages
> > are going to be removed. We have to care about it.
> 
> AFAICS its already done by __steal_page_from_lru(), which is used
> by grab_capturing_pages():
	:
> Pages with reference count zero will be not be moved to the page
> list, and truncated pages seem to be handled nicely later on the
> migration codepath.

Ok, I see no problem about this with the current implementation.


BTW, now I'm just wondering migration_duplicate() should be
called from copy_page_range(), since page-migration and fork()
may work at the same time.

What do you think about this?


Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
