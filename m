Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D00EF6B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 00:06:03 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q92so23389429ioi.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 21:06:03 -0700 (PDT)
Received: from out0-133.mail.aliyun.com (out0-133.mail.aliyun.com. [140.205.0.133])
        by mx.google.com with ESMTP id i123si30928885ioa.113.2016.09.19.21.06.02
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 21:06:03 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <57DF4FEA.9080509@huawei.com> <57E0A2EC.7050809@huawei.com>
In-Reply-To: <57E0A2EC.7050809@huawei.com>
Subject: Re: [question] hugetlb: how to find who use hugetlb?
Date: Tue, 20 Sep 2016 12:05:59 +0800
Message-ID: <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Xishi Qiu' <qiuxishi@huawei.com>, 'Linux MM' <linux-mm@kvack.org>

> > So how to find who use the additional hugetlb?
> > 
Take a peek please at 5d317b2b653 
("mm: hugetlb: proc: add HugetlbPages field to /proc/PID/status")

Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
