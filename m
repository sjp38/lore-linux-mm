Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 522956B0031
	for <linux-mm@kvack.org>; Sat, 18 Jan 2014 03:41:57 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so2768035pab.38
        for <linux-mm@kvack.org>; Sat, 18 Jan 2014 00:41:56 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id xa2si12656148pab.171.2014.01.18.00.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 18 Jan 2014 00:41:56 -0800 (PST)
Message-ID: <52DA3E41.9050202@huawei.com>
Date: Sat, 18 Jan 2014 16:41:37 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kmemleak: add support for re-enable kmemleak at runtime
References: <52D8FA72.8080100@huawei.com> <20140117120436.GC28895@arm.com>
In-Reply-To: <20140117120436.GC28895@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

On 2014/1/17 20:04, Catalin Marinas wrote:

> On Fri, Jan 17, 2014 at 09:40:02AM +0000, Jianguo Wu wrote:
>> Now disabling kmemleak is an irreversible operation, but sometimes
>> we may need to re-enable kmemleak at runtime. So add a knob to enable
>> kmemleak at runtime:
>> echo on > /sys/kernel/debug/kmemleak
> 
> It is irreversible for very good reason: once it missed the initial
> memory allocations, there is no way for kmemleak to build the object
> reference graph and you'll get lots of false positives, pretty much
> making it unusable.
> 

Do you mean we didn't trace memory allocations during kmemleak disable period,
and these memory may reference to new allocated objects after re-enable? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
