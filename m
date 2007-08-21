Message-ID: <46CB01B7.3050201@redhat.com>
Date: Tue, 21 Aug 2007 11:16:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
References: <20070820215040.937296148@sgi.com>
In-Reply-To: <20070820215040.937296148@sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

> 1. First reclaiming non dirty pages. Dirty pages are deferred until reclaim
>    has reestablished the high marks. Then all the dirty pages (the laundry)
>    is written out.

That sounds like a horrendously bad idea.  While one process
is busy freeing all the non dirty pages, other processes can
allocate those pages, leaving you with no memory to free up
the dirty pages!

How exactly are you planning to prevent that problem?

Also, writing out all the dirty pages at once seems like it
could hurt latency quite badly, especially on large systems.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
