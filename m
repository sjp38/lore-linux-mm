Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 83A6C6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 03:22:50 -0400 (EDT)
Date: Thu, 17 Sep 2009 10:20:57 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 0/2] mm: use_mm/unuse_mm
Message-ID: <20090917072056.GA18115@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

This moves use_mm/unuse_mm from aio into mm, and optimizes atomic usage
there. Original patchset also exported use_mm/unuse_mm to modules, for
use by vhost, that bit will come in later when vhost is posted for
inclusion.

Michael S. Tsirkin (2):
  mm: move use_mm/unuse_mm from aio.c to mm/
  mm: reduce atomic use on use_mm fast path

 fs/aio.c                    |   47 +----------------------------------
 include/linux/mmu_context.h |    9 ++++++
 mm/Makefile                 |    2 +-
 mm/mmu_context.c            |   58 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 47 deletions(-)
 create mode 100644 include/linux/mmu_context.h
 create mode 100644 mm/mmu_context.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
