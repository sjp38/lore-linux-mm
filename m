Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5945B6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 02:22:43 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/6] zsmalloc: clean up and fix arch dependency
Date: Wed, 25 Apr 2012 15:23:08 +0900
Message-Id: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patchset has some clean up patches(1-5) and remove 
set_bit, flush_tlb for portability in [6/6].

Minchan Kim (6):
  zsmalloc: use PageFlag macro instead of [set|test]_bit
  zsmalloc: remove unnecessary alignment
  zsmalloc: rename zspage_order with zspage_pages
  zsmalloc: add/fix function comment
  zsmalloc: remove unnecessary type casting
  zsmalloc: make zsmalloc portable

 drivers/staging/zsmalloc/Kconfig         |    4 --
 drivers/staging/zsmalloc/zsmalloc-main.c |   73 +++++++++++++++++-------------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    3 +-
 3 files changed, 43 insertions(+), 37 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
