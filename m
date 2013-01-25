Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E72256B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:46:44 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 12:46:43 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A9EAF6E803C
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:46:40 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PHkfFh316400
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:46:41 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PHkOxZ002929
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:28 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
Date: Fri, 25 Jan 2013 11:46:14 -0600
Message-Id: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

These patches are the first 4 patches of the zswap patchset I
sent out previously.  Some recent commits to zsmalloc and
zcache in staging-next forced a rebase. While I was at it, Nitin
(zsmalloc maintainer) requested I break these 4 patches out from
the zswap patchset, since they stand on their own.

All are already Acked-by Nitin.

Based on staging-next as of today.

Seth Jennings (4):
  staging: zsmalloc: add gfp flags to zs_create_pool
  staging: zsmalloc: remove unused pool name
  staging: zsmalloc: add page alloc/free callbacks
  staging: zsmalloc: make CLASS_DELTA relative to PAGE_SIZE

 drivers/staging/zram/zram_drv.c          |    4 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   60 ++++++++++++++++++------------
 drivers/staging/zsmalloc/zsmalloc.h      |   10 ++++-
 3 files changed, 47 insertions(+), 27 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
