From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 0/7] cpu alloc stage 2
Date: Wed, 05 Nov 2008 17:16:34 -0600
Message-ID: <20081105231634.133252042@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-Id: linux-mm.kvack.org

The second stage of the cpu_alloc patchset can be pulled from

git.kernel.org/pub/scm/linux/kernel/git/christoph/work.git cpu_alloc_stage2

Stage 2 includes the conversion of the page allocator
and slub allocator to the use of the cpu allocator.

It also includes the core of the atomic vs. interrupt cpu ops and uses those
for the vm statistics.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
