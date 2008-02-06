Date: Tue, 5 Feb 2008 19:52:47 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Pull request: DMA pool updates
Message-ID: <20080206025247.GA7705@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Could I ask you to pull the DMA Pool changes detailed below?

All the patches have been posted to linux-kernel before, and various
comments (and acks) have been taken into account.  (see
http://thread.gmane.org/gmane.linux.kernel/609943)

It's a fairly nice performance improvement, so would be good to get in.
It's survived a few hours of *mumble* high-stress database benchmark,
so I have high confidence in its stability.

The following changes since commit 21511abd0a248a3f225d3b611cfabb93124605a7:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.git dmapool

Matthew Wilcox (7):
      Move dmapool.c to mm/ directory
      dmapool: Fix style problems
      Avoid taking waitqueue lock in dmapool
      dmapool: Validate parameters to dma_pool_create
      dmapool: Tidy up includes and add comments
      Change dmapool free block management
      pool: Improve memory usage for devices which can't cross boundaries

 drivers/base/Makefile  |    2 +-
 drivers/base/dmapool.c |  481 ----------------------------------------------
 mm/Makefile            |    1 +
 mm/dmapool.c           |  500 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 502 insertions(+), 482 deletions(-)
 delete mode 100644 drivers/base/dmapool.c
 create mode 100644 mm/dmapool.c

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
