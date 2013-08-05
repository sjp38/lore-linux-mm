Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AAFF56B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:31:12 -0400 (EDT)
Message-ID: <51FF62C0.10105@huawei.com>
Date: Mon, 5 Aug 2013 16:30:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 0/2] cma: do some clean up
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

1. use "PFN_DOWN(r->size)" instead of "r->size >> PAGE_SHIFT".
2. adjust the function structure, one for the success path, 
the other for the failure path.

Xishi Qiu (2):
  cma: use macro PFN_DOWN when converting size to pages
  cma: adjust goto branch in function cma_create_area()

 drivers/base/dma-contiguous.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
