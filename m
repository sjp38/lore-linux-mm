Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA16428
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 07:49:19 -0500
Date: Sun, 24 Jan 1999 13:49:28 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <m1pv85fke1.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990124134751.404A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Jan 1999, Eric W. Biederman wrote:

> AA> extern inline void buffer_get(struct buffer_head *bh)
> AA> {
> AA>         struct page * page = mem_map + MAP_NR(bh->b_data);
> 
> AA>         switch (atomic_read(&page->count))
> AA>         {
> AA>         case 1:
> AA>                 atomic_inc(&page->count);
> AA>                 nr_freeable_pages--;
> 
> This is bogus.   Consider the case when you have 4 buffers per page (common with ext2fs)
> You will way underestimate the number of freeable pages.

I will not only understimate: the kernel will not boot at all ;). It's a
last minute wrong hack I did (I replaced some if with the switch statement
and I did a mistake). See my following post. Thanks.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
