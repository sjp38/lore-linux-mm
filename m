Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 6FD2A6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:22:57 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M8D005GUZTW4ID0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Aug 2012 22:22:56 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M8D00FP3ZTZI590@mmp1.samsung.com> for linux-mm@kvack.org;
 Tue, 07 Aug 2012 22:22:56 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1344187926-22404-1-git-send-email-aaro.koskinen@iki.fi>
In-reply-to: <1344187926-22404-1-git-send-email-aaro.koskinen@iki.fi>
Subject: RE: [PATCH] ARM: dma-mapping: fix atomic allocation alignment
Date: Tue, 07 Aug 2012 15:22:47 +0200
Message-id: <011d01cd749f$be649fa0$3b2ddee0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Aaro Koskinen' <aaro.koskinen@iki.fi>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Aaro,

On Sunday, August 05, 2012 7:32 PM Aaro Koskinen wrote:

> The alignment mask is calculated incorrectly. Fixing the calculation
> makes strange hangs/lockups disappear during the boot with Amstrad E3
> and 3.6-rc1 kernel.
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>

Again, thanks for spotting and fixing the issue. I've applied it to my fixes branch. 
I'm really sorry for introducing such stupid bugs together with my changes.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
