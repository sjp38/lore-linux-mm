Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id B10676B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:13:03 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M68000SJFPLAF70@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 27 Jun 2012 01:13:01 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.147.136])
 by mmp1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTPA id <0M6800GPNFPNK180@mmp1.samsung.com> for
 linux-mm@kvack.org; Wed, 27 Jun 2012 01:13:01 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [announce] pagemap-demo-ng tools
Date: Tue, 26 Jun 2012 18:11:48 +0200
MIME-version: 1.0
Message-id: <201206261811.48256.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>, Kyungmin Park <kyungmin.park@samsung.com>


Hi,

I got agreement from Matt to takeover maintenance of demo scripts
for the /proc/$pid/pagemap and /proc/kpage[count,flags] interfaces
(originally hosted at http://selenic.com/repo/pagemap/).

The updated tools are available at:

	https://github.com/bzolnier/pagemap-demo-ng

Changes include:

* support for recent kernels
* support for platforms using ARCH_PFN_OFFSET (i.e ARM Exynos)
  (needs [1] & [2])
* possibility to work on data captured on another machine
* optional support for monitoring free/used pages (needs [3])
* optional support for monitoring pageblock type changes (needs [4])

[1] http://article.gmane.org/gmane.linux.kernel.mm/79435/
[2] http://article.gmane.org/gmane.linux.kernel.mm/79432/ 
[3] http://article.gmane.org/gmane.linux.kernel.mm/79431/
[4] http://article.gmane.org/gmane.linux.kernel.mm/79433/

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
