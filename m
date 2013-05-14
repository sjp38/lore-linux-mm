Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A2BEE6B0036
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:44 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ib11so931847vcb.35
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:43 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH] Fixes, cleanups, compile warning fixes, and documentation update for Xen tmem driver (v2).
Date: Tue, 14 May 2013 14:09:17 -0400
Message-Id: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com

Heya,

These nine patches fix the tmem driver to:
 - not emit a compile warning anymore (reported by 0 day test compile tool)
 - remove the various nofrontswap, nocleancache, noselfshrinking, noselfballooning,
   selfballooning, selfshrinking bootup options.
 - said options are now folded in the tmem driver as module options and are
   much shorter (and also there are only four of them now).
 - add documentation to explain these parameters in kernel-parameters.txt
 - And lastly add some logic to not enable selfshrinking and selfballooning
   if frontswap functionality is off.

That is it. Tested and ready to go. If nobody objects will put on my queue
for Linus on Monday.

 Documentation/kernel-parameters.txt |   21 ++++++++
 drivers/xen/Kconfig                 |    7 +--
 drivers/xen/tmem.c                  |   87 ++++++++++++++++-------------------
 drivers/xen/xen-selfballoon.c       |   47 ++----------------
 4 files changed, 69 insertions(+), 93 deletions(-)

(oh nice, more deletions!)

Konrad Rzeszutek Wilk (9):
      xen/tmem: Cleanup. Remove the parts that say temporary.
      xen/tmem: Move all of the boot and module parameters to the top of the file.
      xen/tmem: Split out the different module/boot options.
      xen/tmem: Fix compile warning.
      xen/tmem: s/disable_// and change the logic.
      xen/tmem: Remove the boot options and fold them in the tmem.X parameters.
      xen/tmem: Remove the usage of 'noselfshrink' and use 'tmem.selfshrink' bool instead.
      xen/tmem: Remove the usage of '[no|]selfballoon' and use 'tmem.selfballooning' bool instead.
      xen/tmem: Don't use self[ballooning|shrinking] if frontswap is off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
