Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92A966B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 00:29:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r126so15388315oib.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 21:29:35 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id r138si36517917oie.224.2016.09.19.21.29.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 21:29:34 -0700 (PDT)
Message-ID: <57E0BB1C.3040104@huawei.com>
Date: Tue, 20 Sep 2016 12:29:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [question] hugetlb: how to find who use hugetlb?
References: <57DF4FEA.9080509@huawei.com> <57E0A2EC.7050809@huawei.com> <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com>
In-Reply-To: <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Linux MM' <linux-mm@kvack.org>

On 2016/9/20 12:05, Hillf Danton wrote:

>>> So how to find who use the additional hugetlb?
>>>
> Take a peek please at 5d317b2b653 
> ("mm: hugetlb: proc: add HugetlbPages field to /proc/PID/status")
> 
> Hillf
> 

Hi Hillf,

This patch add the count of hugetlb for each process.
If someone use hugetlb, "cat /proc/*/smaps | grep KernelPageSize| grep 2048"
will show something, right? But now it is nothing, and /dev/hugepages is empty.

Thanks,
Xishi Qiu

> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
