Date: Fri, 28 Mar 2008 03:54:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 0/2]: lockless get_user_pages patchset
Message-ID: <20080328025455.GA8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

This patchset It impoves our well known oltp performance thingy by 10% on DB2
on a modest 2 socket x86 system. For a sense of scale, remember numbers being
tossed around like direct-IO giving a 12% improvement; or hugepages giving a 9%
improvement... heh.

I have a powerpc patch as well, but it needs benh to find me a bit in their pte
to use.

These patches are on top of the previous 7 patches just sent.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
