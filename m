Message-Id: <20080121211618.599818000@sgi.com>
Date: Mon, 21 Jan 2008 13:16:18 -0800
From: travis@sgi.com
Subject: [PATCH 0/3] x86: Reduce memory usage for large count NR_CPUs fixup V2 with git-x86
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fixup change NR_CPUS patchset by rebasing on 2.6.24-rc8-mm1
from 2.6.24-rc6-mm1) and adding changes suggested by reviews.

Based on 2.6.24-rc8-mm1 + latest (08/1/21) git-x86

Note there are two versions of this patchset:
	- 2.6.24-rc8-mm1
	- 2.6.24-rc8-mm1 + latest (08/1/21) git-x86

Signed-off-by: Mike Travis <travis@sgi.com>
---
Fixup-V2:
    - pulled the SMP_MAX patch as it's not strictly needed and some
      more work on local cpumask_t variables needs to be done before
      NR_CPUS is allowed to increase.

    - changes to X86_32 have been removed (except for build errors)
---

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
