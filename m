Message-ID: <44C30E33.2090402@redhat.com>
Date: Sun, 23 Jul 2006 01:50:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: inactive-clean list
References: <1153167857.31891.78.camel@lappy>
In-Reply-To: <1153167857.31891.78.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> This patch implements the inactive_clean list spoken of during the VM summit.
> The LRU tail pages will be unmapped and ready to free, but not freeed.
> This gives reclaim an extra chance.

This patch makes it possible to implement Martin Schwidefsky's
hypervisor-based fast page reclaiming for architectures without
millicode - ie. Xen, UML and all other non-s390 architectures.

That could be a big help in heavily loaded virtualized environments.

The fact that it helps prevent the iSCSI memory deadlock is a
huge bonus too, of course :)

-- 
The answer is 42.  What is *your* question?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
