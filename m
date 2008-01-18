Message-Id: <20080118183011.354965000@sgi.com>
Date: Fri, 18 Jan 2008 10:30:11 -0800
From: travis@sgi.com
Subject: [PATCH 0/5] x86: Reduce memory usage for large count NR_CPUs fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fixup change NR_CPUS patchset by rebasing on 2.6.24-rc8-mm1
from 2.6.24-rc6-mm1) and adding changes suggested by reviews.

Additionally, some new config options have been added to enable
large SMP configurations.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
---

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
