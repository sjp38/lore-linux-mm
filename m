Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F23E86B00E7
	for <linux-mm@kvack.org>; Sat, 15 Jan 2011 07:26:39 -0500 (EST)
Date: Sat, 15 Jan 2011 14:26:35 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB changes for v2.6.38-rc1
Message-ID: <alpine.DEB.2.00.1101151426140.4320@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's a fix for potential deadlock while accessing SLUB sysfs files
reported by Bart van Assche. The fix includes an out-of-topic change
to memory hotplug locking from Kamezawa-san.

There's also a minor SLAB cleanup from H Hartley Sweeten included.

                         Pekka

The following changes since commit 38567333a6dabd0f2b4150e9fb6dd8e3ba2985e5:
   Linus Torvalds (1):
         Merge git://git.kernel.org/.../jejb/scsi-post-merge-2.6

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Christoph Lameter (1):
       slub: Avoid use of slub_lock in show_slab_objects()

H Hartley Sweeten (1):
       mm/slab.c: make local symbols static

KAMEZAWA Hiroyuki (1):
       memory hotplug: one more lock on memory hotplug

Pekka Enberg (2):
       Merge branch 'slub/hotplug' into slab/urgent
       Update Pekka's email address in MAINTAINERS

  MAINTAINERS                    |    4 ++--
  include/linux/memory_hotplug.h |    6 ++++++
  mm/memory_hotplug.c            |    4 ++++
  mm/slab.c                      |    6 +++---
  mm/slub.c                      |    4 ++--
  5 files changed, 17 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
