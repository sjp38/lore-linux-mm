Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A71A6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:06:55 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so9334044wiv.17
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:06:55 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id f1si807281wjw.76.2014.08.29.09.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 09:06:54 -0700 (PDT)
From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH 0/4] Tidy up of modules using seq_open()
Date: Fri, 29 Aug 2014 17:06:36 +0100
Message-Id: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk, rob.jones@codethink.co.uk

Many modules use seq_open() when seq_open_private() or
__seq_open_private() would be more appropriate and result in
simpler, cleaner code.

This patch sequence changes those instances in IPC, MM and LIB.

Rob Jones (4):
  ipc: Use __seq_open_private() instead of seq_open()
  mm: Use seq_open_private() instead of seq_open()
  mm: Use __seq_open_private() instead of seq_open()
  lib: Use seq_open_private() instead of seq_open()

 ipc/util.c          |   20 ++++----------------
 lib/dynamic_debug.c |   17 ++---------------
 mm/slab.c           |   22 +++++++++-------------
 mm/vmalloc.c        |   20 +++++---------------
 4 files changed, 20 insertions(+), 59 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
