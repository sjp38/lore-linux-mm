From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16980.20374.889089.242557@gargle.gargle.HOWL>
Date: Thu, 7 Apr 2005 01:07:34 +0400
Subject: Re: "orphaned pagecache memleak fix" question.
In-Reply-To: <20050406122711.1875931a.akpm@osdl.org>
References: <16978.46735.644387.570159@gargle.gargle.HOWL>
	<20050406005804.0045faf9.akpm@osdl.org>
	<16979.53442.695822.909010@gargle.gargle.HOWL>
	<20050406122711.1875931a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea@Suse.DE, linux-mm@kvack.org, Chris Mason <Mason@Suse.COM>
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > I'd prefer to say "the fs _must_ release the page's private metadata,
 > unless, as a special concession to block-backed filesystems, that happens
 > to be buffer_heads".

But this will legalize try_to_free_buffers() hack instead of outlawing
it. The right way is to fix reiserfs v3 (and ext3), unless Andrea or
Chris know the reason why this is impossible to do.

 > 
 > Not for any deep reason: it's just that thus-far we've avoided fiddling
 > witht he LRU queues in filesystems and it'd be nice to retain that.

What about do_invalidatepage() removing page from ->lru when
->invalidatepage() returns error?

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
