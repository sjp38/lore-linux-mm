Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 123CF6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 02:47:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so16731352pab.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 23:47:49 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id q1si33451671paz.267.2016.09.19.23.47.47
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 23:47:48 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <57DF4FEA.9080509@huawei.com> <57E0A2EC.7050809@huawei.com> <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com> <57E0BB1C.3040104@huawei.com>
In-Reply-To: <57E0BB1C.3040104@huawei.com>
Subject: Re: [question] hugetlb: how to find who use hugetlb?
Date: Tue, 20 Sep 2016 14:47:33 +0800
Message-ID: <056901d2130a$ddbf53f0$993dfbd0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Xishi Qiu' <qiuxishi@huawei.com>
Cc: 'Linux MM' <linux-mm@kvack.org>

> 
> If someone use hugetlb, "cat /proc/*/smaps | grep KernelPageSize| grep 2048"
> will show something, right? But now it is nothing, and /dev/hugepages is empty.
> 
With 4.7 or 4.8-rc7?

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
