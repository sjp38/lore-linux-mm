Message-Id: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:21 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 0/9] Reclaim during GFP_ATOMIC allocs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

This is the extended version of the reclaim patchset. It enables reclaim from
clean file backed pages during GFP_ATOMIC allocs. A bit invasive since
may locks must now be taken with saving flags. But it works.

Tested by repeatedly allocating 12MB of memory from the timer interrupt.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
