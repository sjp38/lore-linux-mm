Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA02117
	for <linux-mm@kvack.org>; Thu, 11 Feb 1999 06:12:31 -0500
Date: Thu, 11 Feb 1999 11:12:11 GMT
Message-Id: <199902111112.LAA02474@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large memory system
In-Reply-To: <005001be5517$e06903e0$c80c17ac@clmsdev>
References: <005001be5517$e06903e0$c80c17ac@clmsdev>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 10 Feb 1999 18:02:32 +0100, "Manfred Spraul"
<masp0008@stud.uni-sb.de> said:

> This was not intended as a solution, but as a new idea:
> - the memory > 1 GB is allocated one page at a time.
> - some 'struct page' fields are useless for high memory.
> - if someone who is not prepared to handle high memory finds such a page,
> the computer will crash anyway.
> - high memory needs bounce buffers, so a special if(highmem()) is
> required.

All of this is already in the design.

> ---> no need to use mem_map, add an independant array for high_mem.

No, it makes no sense at all to do this, because you'd have to
implement two separate page caches if you wanted both low-mem and
high-mem cached pages.  It makes far, far more sense to simply expand
mem_map. 

> The advantage is that you can add new fields to such an array (e.g. true
> LRU for a cache), without causing problems in the remaining kernel.

That's really not a problem.  As long as we never hand out a high-mem
page to the kernel unless the kernel explicitly asks for one (for
anonymous pages or page cache), the kernel can never get so confused
anyway. 

> If you restrict the remaining memory to unshared pages (i.e. no COW), then
> the implementation should be really simple:

There is no reason to make this restriction, COW is dead easy.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
