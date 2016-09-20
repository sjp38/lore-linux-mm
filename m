Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70C0E6B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 03:15:23 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g22so32221577ioj.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 00:15:23 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id y34si33350405ioe.30.2016.09.20.00.15.21
        for <linux-mm@kvack.org>;
        Tue, 20 Sep 2016 00:15:23 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <57DF4FEA.9080509@huawei.com> <57E0A2EC.7050809@huawei.com> <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com> <57E0BB1C.3040104@huawei.com> <056901d2130a$ddbf53f0$993dfbd0$@alibaba-inc.com> <57E0E093.6090500@huawei.com>
In-Reply-To: <57E0E093.6090500@huawei.com>
Subject: Re: [question] hugetlb: how to find who use hugetlb?
Date: Tue, 20 Sep 2016 15:15:08 +0800
Message-ID: <057301d2130e$b864cf50$292e6df0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Xishi Qiu' <qiuxishi@huawei.com>
Cc: 'Linux MM' <linux-mm@kvack.org>

> >>
> >> If someone use hugetlb, "cat /proc/*/smaps | grep KernelPageSize| grep 2048"
> >> will show something, right? But now it is nothing, and /dev/hugepages is empty.
> >>
> > With 4.7 or 4.8-rc7?
> 
> RHEL 7.1 (kernel version is v3.10)
> 
Then please deliver the issue directly to your distributor and wait for feedback. 

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
