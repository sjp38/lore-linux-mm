Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA99C6B0007
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 21:38:42 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id o2so6705376pls.10
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 18:38:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14-v6sor394519pls.62.2018.02.02.18.38.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Feb 2018 18:38:40 -0800 (PST)
Date: Sat, 3 Feb 2018 11:38:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug
 198617] New: zswap causing random applications to crash)
Message-ID: <20180203023834.GA21169@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
 <20180203013455.GA739@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180203013455.GA739@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/03/18 10:34), Sergey Senozhatsky wrote:
> so we are basically looking at 4.14-rc0+
[..]
> # first bad commit: [bd4c82c22c367e068acb1ec9ec02be2fac3e09e2] mm, THP, swap: delay splitting THP after swapped out

To re-confirm, disabling CONFIG_TRANSPARENT_HUGEPAGE fixes my 4.15.0-next

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
