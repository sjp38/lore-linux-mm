Message-Id: <20071004223141.413776000@sgi.com>
Date: Thu, 04 Oct 2007 15:31:41 -0700
From: travis@sgi.com
Subject: [PATCH 0/1] ia64: Convert cpu_sibling_map to a per_cpu data array FIX
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

The previous version of this patch missed a code path in
inserting the boot cpu into the cpu sibling and core maps.

This fix corrects that omission.
--

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
