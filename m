Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3D47D6B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 15:19:20 -0400 (EDT)
Received: by gwj16 with SMTP id 16so2763016gwj.14
        for <linux-mm@kvack.org>; Wed, 04 Aug 2010 12:19:19 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 4 Aug 2010 22:19:14 +0300
Message-ID: <AANLkTimHvrwQgq8dwc8oYYTjrv603DXRM_Ggy-JJ56VF@mail.gmail.com>
Subject: [GIT PULL] SLAB updates for 2.6.36-rc0
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Linus,

There's dramatic queued up for this merge window for SLAB. Bulk of the
changes are straight-forward SLUB cleanups from Christoph Lameter's
recent SLAB/SLUB unification patch series but there's also few SLAB
and SLOB fixes thrown into the mix.

                        Pekka

The following changes since commit 9fe6206f400646a2322096b56c59891d530e8d51:
  Linus Torvalds (1):
        Linux 2.6.35

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git
for-linus

Arjan van de Ven (1):
      slab: use deferable timers for its periodic housekeeping

Bob Liu (1):
      SLOB: Free objects to their own list

Christoph Lameter (7):
      slub: Use a constant for a unspecified node.
      SLUB: Constants need UL
      slub: Check kasprintf results in kmem_cache_init()
      slub: Allow removal of slab caches during boot
      slub: Use kmem_cache flags to detect if slab is in debugging mode.
      slub numa: Fix rare allocation from unexpected node
      slub: Allow removal of slab caches during boot

Pekka Enberg (2):
      Revert "slub: Allow removal of slab caches during boot"
      Merge branches 'slab/fixes', 'slob/fixes', 'slub/cleanups' and
'slub/fixes' into for-linus

Xiaotian Feng (1):
      slab: fix caller tracking on !CONFIG_DEBUG_SLAB && CONFIG_TRACING

 include/linux/page-flags.h |    2 -
 include/linux/slab.h       |    6 ++-
 mm/slab.c                  |    2 +-
 mm/slob.c                  |    9 ++++-
 mm/slub.c                  |   86 ++++++++++++++++++++++----------------------
 5 files changed, 56 insertions(+), 49 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
