Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 919FA6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 03:09:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so8710454wmg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 00:09:31 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j6si23829267wjv.96.2016.09.20.00.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 00:09:30 -0700 (PDT)
Message-ID: <57E0E093.6090500@huawei.com>
Date: Tue, 20 Sep 2016 15:09:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [question] hugetlb: how to find who use hugetlb?
References: <57DF4FEA.9080509@huawei.com> <57E0A2EC.7050809@huawei.com> <055801d212f4$4b9c4b60$e2d4e220$@alibaba-inc.com> <57E0BB1C.3040104@huawei.com> <056901d2130a$ddbf53f0$993dfbd0$@alibaba-inc.com>
In-Reply-To: <056901d2130a$ddbf53f0$993dfbd0$@alibaba-inc.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Linux MM' <linux-mm@kvack.org>

On 2016/9/20 14:47, Hillf Danton wrote:

>>
>> If someone use hugetlb, "cat /proc/*/smaps | grep KernelPageSize| grep 2048"
>> will show something, right? But now it is nothing, and /dev/hugepages is empty.
>>
> With 4.7 or 4.8-rc7?
> 

RHEL 7.1 (kernel version is v3.10)

> thanks
> Hillf
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
