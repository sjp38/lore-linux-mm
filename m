Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AD09E4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 06:44:50 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so22763772wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 03:44:50 -0800 (PST)
Received: from mailstore06.sysedata.no (b.mail.tornado.no. [195.159.29.130])
        by mx.google.com with ESMTPS id uv9si23787573wjc.29.2016.02.05.03.44.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 03:44:49 -0800 (PST)
Subject: Re: [RFC] why the amount of cache from "free -m" and /proc/meminfo
 are different?
References: <56B45457.4010702@huawei.com>
From: "Daniel K." <dk@syse.no>
Message-ID: <56B48B2D.4020502@syse.no>
Date: Fri, 5 Feb 2016 11:44:45 +0000
MIME-Version: 1.0
In-Reply-To: <56B45457.4010702@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 02/05/2016 07:50 AM, Xishi Qiu wrote:
> [root@localhost ~]# free -m
>               total        used        free      shared  buff/cache   available
> Mem:          48295         574       41658           8        6062       46344
> Swap:         24191           0       24191
> 
> [root@localhost ~]# cat /proc/meminfo
> Buffers:               0 kB
> Cached:          3727824 kB
> Slab:            2480092 kB

free and meminfo seems to match up pretty well to me.

Are you really asking about display in MB vs kB?

Drop the -m switch to free.

Also, give 'man free' a spin, it explains what's behind the numbers.


Daniel K.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
