Date: Wed, 10 May 2000 18:25:10 +0100 (BST)
From: Dave Jones <dave@denial.force9.co.uk>
Subject: Re: [PATCH] remove_inode_page rewrite.
In-Reply-To: <20000510111035.A685@loth.demon.co.uk>
Message-ID: <Pine.LNX.4.21.0005101821260.17653-100000@neo.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dodd <steved@loth.demon.co.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 May 2000, Steve Dodd wrote:

> Now that invalidate_inode_page isn't calling sync_page, there seems to be
> no reason to drop and retake the spinlock, I agree.

*nod*

> > +	head = &inode->i_mapping->pages;
> That shouldn't be necessary - nobody is likely to change the address of
> inode->i_mapping->pages under us :)

I spotted that, but wasn't entirely sure that the pagecache_lock was
enough to ensure this. With the line above removed also, this means that
invalidate_inode_pages becomes a lot faster as we only pass through the
list once, so maybe holding the spinlock for the whole function isn't such
a big deal.

Even if the race I thought was there doesn't exist, this could be worth
adding for a worthwhile performance increase. I'll do some performance
tests in the next day or so.

regards,

-- 
Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
