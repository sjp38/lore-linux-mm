Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06100
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 13:16:30 -0400
Date: Thu, 23 Jul 1998 15:43:11 +0100
Message-Id: <199807231443.PAA08910@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: 2.1.110 freepages.min change
In-Reply-To: <19980722222736.49195@boole.suse.de>
References: <Pine.LNX.3.96.980722181024.13036A-100000@mirkwood.dummy.home>
	<19980722222736.49195@boole.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 1998 22:27:36 +0200, "Dr. Werner Fink" <werner@suse.de> said:

> The change in fs/dcache.c does not look very well because
> as higher the number given to prune_dache in shrink_dcache_memory
> as more the dcache is pruned ... `0' isn't that good is it?

Werner, have you given it a shot?  With this fix in place, the
dcache/inode fragmentation issues in 2.1 are very dramatically improved
on low memory.  I'm very pleased indeed with this patch: even if it's
only prune_dcache(0), it is still being called much more often when we
get short of memory.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
