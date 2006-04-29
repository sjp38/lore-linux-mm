Date: Fri, 28 Apr 2006 20:22:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: Page Migration patchsets overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Following are 3 patchsets for page migration.

The first patchset contains a series of cleanups that also
contains the right fix for the PageDirty problem.

The second patchset implements read/write migration entries.
This allows us to no longer be dependent on the swap code (page migration
currently will not work if no swap volume is defined) and add additional
features. The speed of page migration increases by 20%. Page migration
can now preserve the write enable bit of the ptes. Useless COW faults
do no longer occur. The kernel can be compiled without SWAP support
and page migration will still work.

The third patchset contains two improvements based on the read/write
migration entries. First we stop incrementing / decrementing rss during
migration. Second we use the migration entries for file backed pages.
This will preserve file ptes during migration and allow repeated
migration of processes. The old code removed those ptes and people
were a bit surprised when the process suddenly got very small.

Patchset against 2.6.17-rc3. There seem to be some bits leftover
from the earlier patches (the removal of the page migration pagecache checks?)
in Andrew's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
