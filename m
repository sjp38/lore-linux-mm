Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1063B82F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 21:32:53 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so4074242pab.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 18:32:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id em5si39387239pbd.203.2015.11.02.18.32.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 18:32:52 -0800 (PST)
Date: Tue, 3 Nov 2015 11:32:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/8] arch: uapi: asm: mman.h: Let MADV_FREE have same
 value for all architectures
Message-ID: <20151103023250.GH17906@bbox>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-4-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1511011542030.11427@eggly.anvils>
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1511011542030.11427@eggly.anvils>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Miller <davem@davemloft.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, Roland Dreier <roland@kernel.org>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, Chen Gang <gang.chen.5i5j@gmail.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>, "deller@gmx.de" <deller@gmx.de>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Sun, Nov 01, 2015 at 04:08:27PM -0800, Hugh Dickins wrote:
> On Fri, 30 Oct 2015, Minchan Kim wrote:
> > From: Chen Gang <gang.chen.5i5j@gmail.com>
> > 
> > For uapi, need try to let all macros have same value, and MADV_FREE is
> > added into main branch recently, so need redefine MADV_FREE for it.
> > 
> > At present, '8' can be shared with all architectures, so redefine it to
> > '8'.
> > 
> > Cc: rth@twiddle.net <rth@twiddle.net>,
> > Cc: ink@jurassic.park.msu.ru <ink@jurassic.park.msu.ru>
> > Cc: mattst88@gmail.com <mattst88@gmail.com>
> > Cc: Ralf Baechle <ralf@linux-mips.org>
> > Cc: jejb@parisc-linux.org <jejb@parisc-linux.org>
> > Cc: deller@gmx.de <deller@gmx.de>
> > Cc: chris@zankel.net <chris@zankel.net>
> > Cc: jcmvbkbc@gmail.com <jcmvbkbc@gmail.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: linux-arch@vger.kernel.org
> > Cc: linux-api@vger.kernel.org
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Let me add
> Acked-by: Hugh Dickins <hughd@google.com>
> to this one too.
> 
> But I have extended your mail's Cc list: Darrick pointed out earlier
> that dietlibc has a Solaris #define MADV_FREE 0x5 in its mman.h,
> and that was in the kernel's sparc mman.h up until 2.6.25.  I doubt
> that presents any obstacle nowadays, but Dave Miller should be Cc'ed.
> 
> I was a little suspicious that 8 is available for MADV_FREE: why did
> the common/generic parameters start at 9 instead of 8 back in 2.6.16?
> I think the answer is that we had MADV_REMOVE coming in from one
> direction, and MADV_DONTFORK coming from another direction, and when
> Roland looked for where to start the commons for MADV_DONTFORK, it
> appeared that 8 was occupied - by MADV_REMOVE; then a little later
> MADV_REMOVE was shifted to become the first of the commons, at 9.

Thanks for Ack, Ccing relevant people and history!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
