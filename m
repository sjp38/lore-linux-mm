From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.25186.861908.523998@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 23:19:14 +0100 (BST)
Subject: Re: simple slab alloc question
In-Reply-To: <Pine.LNX.4.10.9910112007250.26190-100000@imladris.dummy.home>
References: <19991011131021.A952@fred.muc.de>
	<Pine.LNX.4.10.9910112007250.26190-100000@imladris.dummy.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Andi Kleen <ak@muc.de>, Jeff Garzik <jgarzik@pobox.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 20:11:38 +0200 (CEST), Rik van Riel
<riel@nl.linux.org> said:

>> Even other major users get their pages from the page allocator
>> directly (inodes, dcache). These used to be (still are?) a major
>> source of fragmentation, because they tend to wire whole pages
>> down even where there is only a single active inode/dentry on it.

> A zone allocator would not help in this case. A zone
> which has only one active inode/dentry on it is just
> as wired down as a normal page.

It would help.  The problem is that single wired pages make it
impossible to use the adjacent page for larger allocations such as for
kernel stacks or big network frames.  The VM causes the same problem but
to a much lesser extend, as in general we can swap out any VM page given
enough effort.  The fragmentation caused by a pinned inode or dcache
page causes unrecoverable fragmentation.

With a zoned allocater, we can keep these two cases in separate zones
and enormously increase our ability to defragment memory by cleaning VM
pages.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
