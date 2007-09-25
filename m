Message-Id: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:43 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/14] Misc cleanups / fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a collection of fixes and cleanups from the slab defrag,
virtual compound and the large block patchset that are useful
independent of these patchsets and that were rediffed against
2.6.23-rc8-mm1.

1+2	Page cache zeroing simplifications

3-8	vmalloc fixes

9-11	slub cleanups / fixes

12	General capability to take a refcount on a compound page

13	Dentry code consolidation

14	Revert buffer_head patch to get the constructor back.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
