Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 30B886B0254
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 22:36:58 -0500 (EST)
Received: by igdg1 with SMTP id g1so71810800igd.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 19:36:58 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id a100si19672285ioj.130.2015.11.02.19.36.57
        for <linux-mm@kvack.org>;
        Mon, 02 Nov 2015 19:36:57 -0800 (PST)
Date: Mon, 02 Nov 2015 22:36:52 -0500 (EST)
Message-Id: <20151102.223652.1286539054272673801.davem@davemloft.net>
Subject: Re: [PATCH 3/8] arch: uapi: asm: mman.h: Let MADV_FREE have same
 value for all architectures
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151103023651.GI17906@bbox>
References: <alpine.LSU.2.11.1511011542030.11427@eggly.anvils>
	<20151103023250.GH17906@bbox>
	<20151103023651.GI17906@bbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mtk.manpages@gmail.com, linux-api@vger.kernel.org, hannes@cmpxchg.org, zhangyanfei@cn.fujitsu.com, riel@redhat.com, mgorman@suse.de, kosaki.motohiro@jp.fujitsu.com, darrick.wong@oracle.com, roland@kernel.org, je@fb.com, danielmicay@gmail.com, kirill@shutemov.name, mhocko@suse.cz, yalin.wang2010@gmail.com, shli@kernel.org, gang.chen.5i5j@gmail.com, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, ralf@linux-mips.org, jejb@parisc-linux.org, deller@gmx.de, chris@zankel.net, jcmvbkbc@gmail.com, arnd@arndb.de, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

From: Minchan Kim <minchan@kernel.org>
Date: Tue, 3 Nov 2015 11:36:51 +0900

> For the convenience for Dave, I found this.
> 
> commit ec98c6b9b47df6df1c1fa6cf3d427414f8c2cf16
> Author: David S. Miller <davem@davemloft.net>
> Date:   Sun Apr 20 02:14:23 2008 -0700
> 
>     [SPARC]: Remove SunOS and Solaris binary support.
>     
>     As per Documentation/feature-removal-schedule.txt
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Hello Dave,
> Could you confirm it?

I don't understand what you want me to confirm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
