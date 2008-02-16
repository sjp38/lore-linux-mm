Message-Id: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:18 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/18] Page cache: Replace PAGE_CACHE_xx with inline functions V4
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

This patchset cleans up page cache handling by replacing
open coded shifts and adds with inline function calls.

The ultimate goal is to replace all uses of PAGE_CACHE_xxx in the
kernel through the use of these functions. All the functions take
a mapping parameter. The mapping parameter is required if we want
to support large block sizes in filesystems and block devices.

Patchset against upstream as of today (2.6.25-rc2)

Patchset can be pulled from

git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git pagecache-inline

V2->V4:
- Rediff to upstream. Surprisingly no rejects at all so it seems that all
  of the pagecache patches that were in mm were merged. Just had to refresh
  the patches.

V2->V3:
- Audit to check that uses of page->mapping are valid. Improve a couple
  of places. Make it clearer how the mappings are determined and handled
  (see the comments of each patch for detailed descriptions).
- Use a consistent method to determine the mapping if a function already
  does determine the inode via page->mapping->host.

V1->V2:
- Review by Dave Chinner. Multiple improvements and fixes.
- Review by Fengguand Wu with more improvements.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
