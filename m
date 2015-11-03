Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7A77582F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 23:31:18 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so7119846pac.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 20:31:18 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id zo6si40141510pbc.29.2015.11.02.20.31.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 20:31:17 -0800 (PST)
Date: Tue, 3 Nov 2015 13:31:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/8] arch: uapi: asm: mman.h: Let MADV_FREE have same
 value for all architectures
Message-ID: <20151103043115.GK17906@bbox>
References: <alpine.LSU.2.11.1511011542030.11427@eggly.anvils>
 <20151103023250.GH17906@bbox>
 <20151103023651.GI17906@bbox>
 <20151102.223652.1286539054272673801.davem@davemloft.net>
MIME-Version: 1.0
In-Reply-To: <20151102.223652.1286539054272673801.davem@davemloft.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mtk.manpages@gmail.com, linux-api@vger.kernel.org, hannes@cmpxchg.org, zhangyanfei@cn.fujitsu.com, riel@redhat.com, mgorman@suse.de, kosaki.motohiro@jp.fujitsu.com, darrick.wong@oracle.com, roland@kernel.org, je@fb.com, danielmicay@gmail.com, kirill@shutemov.name, mhocko@suse.cz, yalin.wang2010@gmail.com, shli@kernel.org, gang.chen.5i5j@gmail.com, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, ralf@linux-mips.org, jejb@parisc-linux.org, deller@gmx.de, chris@zankel.net, jcmvbkbc@gmail.com, arnd@arndb.de, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Mon, Nov 02, 2015 at 10:36:52PM -0500, David Miller wrote:
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 3 Nov 2015 11:36:51 +0900
> 
> > For the convenience for Dave, I found this.
> > 
> > commit ec98c6b9b47df6df1c1fa6cf3d427414f8c2cf16
> > Author: David S. Miller <davem@davemloft.net>
> > Date:   Sun Apr 20 02:14:23 2008 -0700
> > 
> >     [SPARC]: Remove SunOS and Solaris binary support.
> >     
> >     As per Documentation/feature-removal-schedule.txt
> >     
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > Hello Dave,
> > Could you confirm it?
> 
> I don't understand what you want me to confirm.

Sorry for lacking of the information.

Is it okay to use number 8 for upcoming madvise(addr, len, MADV_FREE)
feature in sparc arch?

The reason to ask is that Darrick pointed out earlier that
dietlibc has a Solaris #define MADV_FREE 0x5 in its mman.h
and Hugh pointed out that was in the kernel's sparc mman.h up
until 2.6.25 but disappeared now so I guess it's okay to use the
number 8 for MADV_FREE in sparc but want to confirm from you.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
