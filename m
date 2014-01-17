Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id DD9556B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 07:05:09 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so3993881pbb.17
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 04:05:09 -0800 (PST)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id fv4si9978239pbd.2.2014.01.17.04.05.08
        for <linux-mm@kvack.org>;
        Fri, 17 Jan 2014 04:05:08 -0800 (PST)
Date: Fri, 17 Jan 2014 12:04:36 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm/kmemleak: add support for re-enable kmemleak at
 runtime
Message-ID: <20140117120436.GC28895@arm.com>
References: <52D8FA72.8080100@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D8FA72.8080100@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

On Fri, Jan 17, 2014 at 09:40:02AM +0000, Jianguo Wu wrote:
> Now disabling kmemleak is an irreversible operation, but sometimes
> we may need to re-enable kmemleak at runtime. So add a knob to enable
> kmemleak at runtime:
> echo on > /sys/kernel/debug/kmemleak

It is irreversible for very good reason: once it missed the initial
memory allocations, there is no way for kmemleak to build the object
reference graph and you'll get lots of false positives, pretty much
making it unusable.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
