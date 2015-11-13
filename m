Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 99AA06B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:18:22 -0500 (EST)
Received: by ioc74 with SMTP id 74so88581768ioc.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 22:18:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id j18si22968665ioe.14.2015.11.12.22.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Nov 2015 22:18:22 -0800 (PST)
Date: Fri, 13 Nov 2015 15:18:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 03/17] arch: uapi: asm: mman.h: Let MADV_FREE have
 same value for all architectures
Message-ID: <20151113061855.GD5235@bbox>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-4-git-send-email-minchan@kernel.org>
 <20151112112753.GC22481@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20151112112753.GC22481@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Chen Gang <gang.chen.5i5j@gmail.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>, "deller@gmx.de" <deller@gmx.de>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, roland@kernel.org, darrick.wong@oracle.com, davem@davemloft.net

On Thu, Nov 12, 2015 at 01:27:53PM +0200, Kirill A. Shutemov wrote:
> On Thu, Nov 12, 2015 at 01:32:59PM +0900, Minchan Kim wrote:
> > From: Chen Gang <gang.chen.5i5j@gmail.com>
> > 
> > For uapi, need try to let all macros have same value, and MADV_FREE is
> > added into main branch recently, so need redefine MADV_FREE for it.
> > 
> > At present, '8' can be shared with all architectures, so redefine it to
> > '8'.
> 
> Why not fold the patch into thre previous one?

Because it was a little bit arguable at that time whether we could use
number 8 for all of arches. If so, simply I can drop this patch only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
