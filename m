Date: Tue, 3 Oct 2000 01:25:46 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001003012546.C27493@athlon.random>
References: <Pine.LNX.4.21.0010021956410.1067-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010030127050.17037-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010030127050.17037-100000@elte.hu>; from mingo@elte.hu on Tue, Oct 03, 2000 at 01:29:27AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 03, 2000 at 01:29:27AM +0200, Ingo Molnar wrote:
> it can and does lose them - but only all of them. Aging OTOH is a per-bh
> thing, this kind of granularity is simply not present in the current
> page->buffers handling. This is all i wanted to mention. Not unsolvable,

I'm pretty sure it doesn't worth the per-bh thing. And even if it would make
any difference with a 1k fs for good performance 4k blksize is necessary anyway
for other reasons.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
