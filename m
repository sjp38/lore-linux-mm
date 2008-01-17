Message-Id: <20080117223546.419383000@sgi.com>
Date: Thu, 17 Jan 2008 14:35:46 -0800
From: travis@sgi.com
Subject: [PATCH 0/3] x86: Reduce memory and intra-node effects with large count NR_CPUs fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fixup change NR_CPUS patchset by rebasing on 2.6.24-rc8-mm1 (from 2.6.24-rc6-mm1)
and adding last minute changes suggested by reviews.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
