Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 45C356B0038
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 05:58:55 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so17071383pac.39
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 02:58:54 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id mt7si10167040pdb.135.2014.09.03.02.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 02:58:18 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 3 Sep 2014 17:57:57 +0800
Subject: free initrd / cma pages problems with memblock
Message-ID: <35FD53F367049845BC99AC72306C23D103CDBFBFB00B@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'linux@arm.linux.org.uk'" <linux@arm.linux.org.uk>, "'santosh.shilimkar@ti.com'" <santosh.shilimkar@ti.com>, "'grant.likely@linaro.org'" <grant.likely@linaro.org>, "'robh@kernel.org'" <robh@kernel.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'m.szyprowski@samsung.com'" <m.szyprowski@samsung.com>, "'lauraa@codeaurora.org'" <lauraa@codeaurora.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>"'m.szyprowski@samsung.com'" <m.szyprowski@samsung.com>"'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'iamjoonsoo.kim@lge.com'" <iamjoonsoo.kim@lge.com>, "'mina86@mina86.com'" <mina86@mina86.com>, "'aneesh.kumar@linux.vnet.ibm.com'" <aneesh.kumar@linux.vnet.ibm.com>"'lauraa@codeaurora.org'" <lauraa@codeaurora.org>, "'gioh.kim@lge.com'" <gioh.kim@lge.com>, "'michael.opdenacker@free-electrons.com'" <michael.opdenacker@free-electrons.com>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

Hi=20


I found the freed reserved memory by free_initrd_mem( ) and  cma_activate_a=
rea( )
Are still marked as reserved in /sys/kernel/debug/memblock/reserved .

I think This is not correct and not suitable for memory debug,
Why not also call memblock_free during these functions?
So that /sys/kernel/debug/memblock/reserved only mark really reserved memor=
y as reserved .




Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
