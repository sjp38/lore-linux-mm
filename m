Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 298C66B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 12:34:41 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 10:34:40 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0551B19D8058
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 10:33:35 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25HXauc254372
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:37 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25HXaPv031734
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:36 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/5] staging: zsmalloc: remove SPARSEMEM dependency
Date: Mon,  5 Mar 2012 11:33:19 -0600
Message-Id: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch series removes the dependency zsmalloc has on SPARSEMEM;
more specifically the assumption that MAX_PHYSMEM_BITS is defined.

Based on greg/staging-next.

Seth Jennings (5):
  staging: zsmalloc: move object/handle masking defines
  staging: zsmalloc: add ZS_MAX_PAGES_PER_ZSPAGE
  staging: zsmalloc: calculate MAX_PHYSMEM_BITS if not defined
  staging: zsmalloc: change ZS_MIN_ALLOC_SIZE
  staging: zsmalloc: remove SPARSEMEM dep from Kconfig

 drivers/staging/zsmalloc/Kconfig         |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   14 +---------
 drivers/staging/zsmalloc/zsmalloc_int.h  |   43 +++++++++++++++++++++++++-----
 3 files changed, 38 insertions(+), 21 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
