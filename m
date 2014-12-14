Return-Path: <owner-linux-mm@kvack.org>
Date: Sun, 14 Dec 2014 15:22:24 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [GIT PULL] aio: changes for 3.19
Message-ID: <20141214202224.GH2672@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-aio@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello Linus & everyone,

The following changes since commit b2776bf7149bddd1f4161f14f79520f17fc1d71d:

  Linux 3.18 (2014-12-07 14:21:05 -0800)

are available in the git repository at:

  git://git.kvack.org/~bcrl/aio-next.git master

for you to fetch changes up to 5f785de588735306ec4d7c875caf9d28481c8b21:

  aio: Skip timer for io_getevents if timeout=0 (2014-12-13 17:50:20 -0500)

----------------------------------------------------------------
Fam Zheng (1):
      aio: Skip timer for io_getevents if timeout=0

Pavel Emelyanov (1):
      aio: Make it possible to remap aio ring

 fs/aio.c           | 33 +++++++++++++++++++++++++++++++--
 include/linux/fs.h |  1 +
 mm/mremap.c        |  3 ++-
 3 files changed, 34 insertions(+), 3 deletions(-)

Regards,

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
