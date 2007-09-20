Date: Thu, 20 Sep 2007 13:23:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 0/9] oom killer serialization
Message-ID: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Third version of the OOM serialization patchset.  Zone locking is now
done with a newly-introduced flag in struct zone and the per-cpuset
oom_kill_asking_task has been extracted out to become a full-fledged
sysctl.

Thanks to Christoph Lameter and Paul Jackson for their help and review of
this patchset.

Applied on 2.6.23-rc7.
---
 Documentation/sysctl/vm.txt |   22 +++++++++
 drivers/char/sysrq.c        |    1 +
 include/linux/cpuset.h      |   12 ++---
 include/linux/mmzone.h      |   33 ++++++++++++--
 include/linux/oom.h         |   23 +++++++++-
 include/linux/swap.h        |    5 --
 kernel/cpuset.c             |   70 ++++-----------------------
 kernel/sysctl.c             |    9 ++++
 mm/oom_kill.c               |  107 +++++++++++++++++++++++++++++++------------
 mm/page_alloc.c             |   23 +++++++--
 mm/vmscan.c                 |   25 +++++-----
 mm/vmstat.c                 |    2 +-
 12 files changed, 206 insertions(+), 126 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
