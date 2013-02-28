Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7E92A6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:50 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:44:49 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3C89B6E804C
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:44 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKijQn270516
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKijgX030902
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:45 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC][PATCH 00/24] DNUMA: Runtime NUMA memory layout reconfiguration
Date: Thu, 28 Feb 2013 12:44:08 -0800
Message-Id: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <20130228024112.GA24970@negative>
References: <20130228024112.GA24970@negative>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Some people asked me to send the email patches for this instead of just posting a git tree link

For reference, this is the original message:
	http://lkml.org/lkml/2013/2/27/374

--

 arch/x86/Kconfig                 |   1 -
 arch/x86/include/asm/sparsemem.h |   4 +-
 arch/x86/mm/numa.c               |  32 +++-
 include/linux/dnuma.h            |  96 +++++++++++
 include/linux/memlayout.h        | 111 +++++++++++++
 include/linux/memory_hotplug.h   |   4 +
 include/linux/mm.h               |   7 +-
 include/linux/page-flags.h       |  18 ++
 include/linux/rbtree.h           |  11 ++
 init/main.c                      |   2 +
 lib/rbtree.c                     |  40 +++++
 mm/Kconfig                       |  44 +++++
 mm/Makefile                      |   2 +
 mm/dnuma.c                       | 351 +++++++++++++++++++++++++++++++++++++++
 mm/internal.h                    |  13 +-
 mm/memlayout-debugfs.c           | 323 +++++++++++++++++++++++++++++++++++
 mm/memlayout-debugfs.h           |  35 ++++
 mm/memlayout.c                   | 267 +++++++++++++++++++++++++++++
 mm/memory_hotplug.c              |  53 +++---
 mm/page_alloc.c                  | 112 +++++++++++--
 20 files changed, 1486 insertions(+), 40 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
