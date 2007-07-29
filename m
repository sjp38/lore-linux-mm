Message-ID: <46AC1297.9030009@redhat.com>
Date: Sun, 29 Jul 2007 00:07:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: How can we make page replacement smarter (was: swap-prefetch)
References: <200707272243.02336.a1426z@gawab.com> <200707280717.41250.a1426z@gawab.com> <46AAEFC4.8000006@redhat.com> <200707281411.57823.a1426z@gawab.com>
In-Reply-To: <200707281411.57823.a1426z@gawab.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Al Boldi wrote:
> Chris Snook wrote:

>> At best, reads can be read-ahead and cached, which is why
>> sequential swap-in sucks less.  On-demand reads are as expensive as I/O
>> can get.
> 
> Which means that it should be at least as fast as swap-out, even faster 
> because write to disk is usually slower than read on modern disks.  But 
> linux currently shows a distinct 2x slowdown for sequential swap-in wrt 
> swap-out. 

That's because writes are faster than reads in moderate
quantities.

The disk caches writes, allowing the OS to write a whole
bunch of data into the disk cache and the disk can optimize
the IO a bit internally.

The same optimization is not possible for reads.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
