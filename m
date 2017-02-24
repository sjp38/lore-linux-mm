Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 12E136B0388
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:05:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p185so10596386pfb.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:05:53 -0800 (PST)
Received: from localhost.localdomain ([14.140.2.178])
        by mx.google.com with ESMTP id w31si7733332pla.116.2017.02.24.08.05.36
        for <linux-mm@kvack.org>;
        Fri, 24 Feb 2017 08:05:37 -0800 (PST)
From: Mahipal Challa <Mahipal.Challa@cavium.com>
Subject: [PATCH v2 0/1] mm: zswap - crypto acomp/scomp support
Date: Fri, 24 Feb 2017 21:35:12 +0530
Message-Id: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@redhat.com, ddstreet@ieee.org, linux-mm@kvack.org
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, pathreya@cavium.com, vnair@cavium.com, Mahipal Challa <Mahipal.Challa@cavium.com>

Hi Seth, Dan,

This series adds support for kernel's new crypto acomp/scomp compression &
decompression framework to zswap. We verified these changes using the
kernel's crypto deflate-scomp, lzo-scomp modules and Cavium's ThunderX
ZIP driver (we have submitted the Cavium's ThunderX ZIP driver v2 
patches with acomp/scomp support to "linux-crypto" which are under review).

Addressed review comments from the v1 patch.
 - Implemented the callback function for request completion.
 - Added "__percpu" results for acomp request completion.

Patch is on top of 'https://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git'
repository "master" branch.

Please review the patch.

Regards,
Mahipal

Mahipal Challa (1):
  mm: zswap - Add crypto acomp/scomp framework support

 mm/zswap.c | 192 +++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 162 insertions(+), 30 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
