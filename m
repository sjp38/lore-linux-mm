Date: Wed, 19 Sep 2007 11:24:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 0/8] oom killer updates
Message-ID: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is an updated replacement of all patches posted by me to
linux-mm on September 18, 2007.
---
 Documentation/cpusets.txt |    6 +-
 drivers/char/sysrq.c      |    1 +
 include/linux/cpuset.h    |   13 ++--
 include/linux/oom.h       |   23 +++++-
 include/linux/swap.h      |    5 -
 kernel/cpuset.c           |   61 ++++++++-------
 mm/oom_kill.c             |  197 ++++++++++++++++++++++++++++++++++++---------
 mm/page_alloc.c           |   15 +++-
 8 files changed, 240 insertions(+), 81 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
