Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 35B4B440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 20:23:05 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id xk3so103752615obc.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:23:05 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id w184si10110776oig.131.2016.02.05.17.23.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 17:23:04 -0800 (PST)
Message-ID: <56B54A2C.5010407@huawei.com>
Date: Sat, 6 Feb 2016 09:19:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] why the amount of cache from "free -m" and /proc/meminfo
 are different?
References: <56B45457.4010702@huawei.com> <56B48B2D.4020502@syse.no>
In-Reply-To: <56B48B2D.4020502@syse.no>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Daniel K." <dk@syse.no>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/2/5 19:44, Daniel K. wrote:

> On 02/05/2016 07:50 AM, Xishi Qiu wrote:
>> [root@localhost ~]# free -m
>>               total        used        free      shared  buff/cache   available
>> Mem:          48295         574       41658           8        6062       46344
>> Swap:         24191           0       24191
>>
>> [root@localhost ~]# cat /proc/meminfo
>> Buffers:               0 kB
>> Cached:          3727824 kB
>> Slab:            2480092 kB
> 
> free and meminfo seems to match up pretty well to me.
> 
> Are you really asking about display in MB vs kB?
> 

Hi Daniel,

No, I mean "Cached: 3727824 kB" and "buff/cache 6062M" are different.

Does "buff/cache" include Buffers, Cached, and Slab?

Thanks,
Xishi Qiu

> Drop the -m switch to free.
> 
> Also, give 'man free' a spin, it explains what's behind the numbers.
> 
> 
> Daniel K.
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
