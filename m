Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7B66B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:27:56 -0500 (EST)
Received: by wmec201 with SMTP id c201so27961259wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:27:55 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id f3si18010951wje.74.2015.11.12.03.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 03:27:55 -0800 (PST)
Received: by wmec201 with SMTP id c201so86798104wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:27:55 -0800 (PST)
Date: Thu, 12 Nov 2015 13:27:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/17] arch: uapi: asm: mman.h: Let MADV_FREE have
 same value for all architectures
Message-ID: <20151112112753.GC22481@node.shutemov.name>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447302793-5376-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Chen Gang <gang.chen.5i5j@gmail.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>, "deller@gmx.de" <deller@gmx.de>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, roland@kernel.org, darrick.wong@oracle.com, davem@davemloft.net

On Thu, Nov 12, 2015 at 01:32:59PM +0900, Minchan Kim wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> For uapi, need try to let all macros have same value, and MADV_FREE is
> added into main branch recently, so need redefine MADV_FREE for it.
> 
> At present, '8' can be shared with all architectures, so redefine it to
> '8'.

Why not fold the patch into thre previous one?
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
