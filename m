Date: Mon, 4 Feb 2008 12:08:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] SLUB updates for 2.6.25
Message-ID: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Updates for slub are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-linus

Christoph Lameter (5):
      SLUB: Fix sysfs refcounting
      Move count_partial before kmem_cache_shrink
      SLUB: rename defrag to remote_node_defrag_ratio
      Add parameter to add_partial to avoid having two functions
      Explain kmem_cache_cpu fields

Harvey Harrison (1):
      slub: fix shadowed variable sparse warnings

Pekka Enberg (1):
      SLUB: Fix coding style violations

root (1):
      SLUB: Do not upset lockdep

 include/linux/slub_def.h |   15 ++--
 mm/slub.c                |  182 +++++++++++++++++++++++++---------------------
 2 files changed, 108 insertions(+), 89 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
