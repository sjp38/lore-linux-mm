Date: Sun, 7 Jul 2002 17:59:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: vm lock contention reduction
Message-ID: <20020708005920.GD25360@holomorphy.com>
References: <3D26304C.51FAE560@zip.com.au> <Pine.LNX.4.44L.0207052110590.8346-100000@imladris.surriel.com> <3D263E70.7B8F5307@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D263E70.7B8F5307@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
>> But it is, mmap() and anonymous memory don't trigger writeback.

On Fri, Jul 05, 2002 at 05:48:48PM -0700, Andrew Morton wrote:
> That's different.  Bill hit a problem just running tiobench.
> We can run balance_dirty_pages() when a COW copyout is performed,
> which will approximately improve things.
> But the whole idea of the dirty memory thresholds just seems bust,
> really.  Because how do you pick the thresholds?  40%.  Bah.

I don't know what the answer should be, but I can certainly demonstrate
this in a rather uninteresting situation (4GB, 4cpu's, 1 disk, 16 tasks).

But I can concur with that evaluation. In my esteem fixed fractions of
memory don't have a very direct relationship to what's going on.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
