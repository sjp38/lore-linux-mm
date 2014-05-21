Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1076B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 22:27:04 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so1058500lab.41
        for <linux-mm@kvack.org>; Tue, 20 May 2014 19:27:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q3si1938995lbj.35.2014.05.20.19.27.01
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 19:27:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Date: Tue, 20 May 2014 22:26:30 -0400
Message-Id: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

This patchset adds a new procfs interface to extrace information about
pagecache status. In-kernel tool tools/vm/page-types.c has already some
code for pagecache scanning without kernel's help, but it's not free
from measurement-disturbance, so here I'm suggesting another approach.

Patch 1/4 changes radix tree API to support ranged iteration as a preparation
for patch 2/4 which adds /proc/kpagecache. Patch 3/4 changes page-types to
use the interface in file scanning mode. Patch 4/4 is documentation update.

This patchset were previously posted as a part of memory error reporting
patchset (http://lwn.net/Articles/590690/), so changelogs in individual
patches are changes from that version.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (4):
      radix-tree: add end_index to support ranged iteration
      fs/proc/page.c: introduce /proc/kpagecache interface
      tools/vm/page-types.c: rework on file cache scanning mode
      Documentation: update Documentation/vm/pagemap.txt

 Documentation/vm/pagemap.txt  |  29 +++++
 drivers/gpu/drm/qxl/qxl_ttm.c |   2 +-
 fs/proc/page.c                | 105 ++++++++++++++++
 include/linux/fs.h            |   9 +-
 include/linux/radix-tree.h    |  27 +++--
 kernel/irq/irqdomain.c        |   2 +-
 lib/radix-tree.c              |   8 +-
 mm/filemap.c                  |   8 +-
 tools/vm/page-types.c         | 276 +++++++++++++++++-------------------------
 9 files changed, 284 insertions(+), 182 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
