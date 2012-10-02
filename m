Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C8F346B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:26:06 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:26:01 -0400 (EDT)
Message-Id: <20121002.182601.845433592794197720.davem@davemloft.net>
Subject: [PATCH 0/8] THP support for Sparc64
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


Here is a set of patches that add THP support for sparc64.

A few of them are relatively minor portability issues I ran into.
Like the MIPS guys I hit the update_mmu_cache() typing issue so I have
a patch for that here.

It is very likely that I need the ACCESSED bit handling fix the
ARM folks have been posting recently as well.

On the sparc64 side the biggest issue was moving to only supporting
4MB pages and then realigning the page tables so that the PMDs map 4MB
(instead of 8MB as they do now).

The rest was just trial and error, running tests, and fixing bugs.

A familiar test case that makes 5 million random accesses to a 1GB
memory area goes from 20 seconds down to 0.43 seconds with THP enabled
on my SPARC T4-2 box.

Signed-off-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
