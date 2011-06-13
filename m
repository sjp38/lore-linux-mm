Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 595AA6B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 15:37:35 -0400 (EDT)
Date: Mon, 13 Jun 2011 22:37:30 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Subject: [GIT PULL] SLAB fixes
Message-ID: <alpine.DEB.2.00.1106132237110.5454@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's fixes to both SLUB and SLAB. The first fix is needed to fix boot
problems on some non-x86 architectures and the latter fixes caller tracking in
SLAB debugging code.

                         Pekka

The following changes since commit cb0a02ecf95e5f47d92e7d4c513cc1f7aeb40cda:
   Linus Torvalds (1):
         Merge branch 'irq-urgent-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Chris Metcalf (1):
       slub: always align cpu_slab to honor cmpxchg_double requirement

Suleiman Souhlal (1):
       SLAB: Record actual last user of freed objects.

  include/linux/percpu.h |    3 +++
  mm/slab.c              |    9 +++++----
  mm/slub.c              |   12 ++++--------
  3 files changed, 12 insertions(+), 12 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
