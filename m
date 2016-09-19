Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806656B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 22:43:02 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu12so283484481pac.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 19:43:02 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id xt5si26237785pab.68.2016.09.18.19.43.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 19:43:01 -0700 (PDT)
Message-ID: <57DF4FEA.9080509@huawei.com>
Date: Mon, 19 Sep 2016 10:39:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [question] hugetlb: how to find who use hugetlb?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On my system, I set HugePages_Total to 2G(1024 x 2M), and I use 1G hugetlb,
but the HugePages_Free is not 1G(512 x 2M), it is 280(280 x 2M) left,
HugePages_Rsvd is 0, it seems someone use 232(232 x 2M) hugetlb additionally.

So how to find who use the additional hugetlb? 

I search every process and find the total hugetlb size is only 1G,
cat /proc/xx/smaps | grep KernelPageSize, then account the vma size
which KernelPageSize is 2048 kB.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
