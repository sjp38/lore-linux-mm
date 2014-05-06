Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDEE6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 19:24:15 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so174619pdi.23
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:24:14 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id ho7si12758672pad.110.2014.05.06.16.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 16:24:14 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so186639pab.33
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:24:13 -0700 (PDT)
From: Marc Carino <marc.ceeeee@gmail.com>
Subject: [PATCH] cma: increase CMA_ALIGNMENT upper limit to 12
Date: Tue,  6 May 2014 16:23:55 -0700
Message-Id: <1399418636-31114-1-git-send-email-marc.ceeeee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Marc Carino <marc.ceeeee@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org

Certain platforms contain peripherals which have contiguous
memory alignment requirements, necessitating the use of the alignment
argument when obtaining CMA memory. The current default maximum
CMA_ALIGNMENT of order 9 translates into a 1MB alignment on systems
with a 4K page size. To accommodate systems with peripherals with even
larger alignment requirements, increase the upper-bound of
CMA_ALIGNMENT from order 9 to order 12.

Marc Carino (1):
  cma: increase CMA_ALIGNMENT upper limit to 12

 drivers/base/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
