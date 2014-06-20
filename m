Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 09E4E6B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:46:07 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so2559852pad.35
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:46:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hq3si7990305pad.87.2014.06.19.19.46.06
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:46:07 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:45:14 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 141/230] drivers/i2c/busses/i2c-omap.c:486:19:
 warning: comparison of distinct pointer types lacks a cast
Message-ID: <53a3a03a.KEnuJ0hB2e7iFrXK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 99c369839f847d2cc4b8e759a9c57c925592efa2 [141/230] include/linux/kernel.h: rewrite min3, max3 and clamp using min and max
config: make ARCH=arm omap2plus_defconfig

All warnings:

   drivers/i2c/busses/i2c-omap.c: In function 'omap_i2c_resize_fifo':
>> drivers/i2c/busses/i2c-omap.c:486:19: warning: comparison of distinct pointer types lacks a cast [enabled by default]

vim +486 drivers/i2c/busses/i2c-omap.c

010d442c4a Komal Shah   2006-08-13  470  }
010d442c4a Komal Shah   2006-08-13  471  
dd74548dde Felipe Balbi 2012-09-12  472  static void omap_i2c_resize_fifo(struct omap_i2c_dev *dev, u8 size, bool is_rx)
dd74548dde Felipe Balbi 2012-09-12  473  {
dd74548dde Felipe Balbi 2012-09-12  474  	u16		buf;
dd74548dde Felipe Balbi 2012-09-12  475  
dd74548dde Felipe Balbi 2012-09-12  476  	if (dev->flags & OMAP_I2C_FLAG_NO_FIFO)
dd74548dde Felipe Balbi 2012-09-12  477  		return;
dd74548dde Felipe Balbi 2012-09-12  478  
dd74548dde Felipe Balbi 2012-09-12  479  	/*
dd74548dde Felipe Balbi 2012-09-12  480  	 * Set up notification threshold based on message size. We're doing
dd74548dde Felipe Balbi 2012-09-12  481  	 * this to try and avoid draining feature as much as possible. Whenever
dd74548dde Felipe Balbi 2012-09-12  482  	 * we have big messages to transfer (bigger than our total fifo size)
dd74548dde Felipe Balbi 2012-09-12  483  	 * then we might use draining feature to transfer the remaining bytes.
dd74548dde Felipe Balbi 2012-09-12  484  	 */
dd74548dde Felipe Balbi 2012-09-12  485  
dd74548dde Felipe Balbi 2012-09-12 @486  	dev->threshold = clamp(size, (u8) 1, dev->fifo_size);
dd74548dde Felipe Balbi 2012-09-12  487  
dd74548dde Felipe Balbi 2012-09-12  488  	buf = omap_i2c_read_reg(dev, OMAP_I2C_BUF_REG);
dd74548dde Felipe Balbi 2012-09-12  489  
dd74548dde Felipe Balbi 2012-09-12  490  	if (is_rx) {
dd74548dde Felipe Balbi 2012-09-12  491  		/* Clear RX Threshold */
dd74548dde Felipe Balbi 2012-09-12  492  		buf &= ~(0x3f << 8);
dd74548dde Felipe Balbi 2012-09-12  493  		buf |= ((dev->threshold - 1) << 8) | OMAP_I2C_BUF_RXFIF_CLR;
dd74548dde Felipe Balbi 2012-09-12  494  	} else {

:::::: The code at line 486 was first introduced by commit
:::::: dd74548ddece4b9d68e5528287a272fa552c81d0 i2c: omap: resize fifos before each message

:::::: TO: Felipe Balbi <balbi@ti.com>
:::::: CC: Wolfram Sang <w.sang@pengutronix.de>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
