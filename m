Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9B7B6B0003
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 21:31:07 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 3so674102pla.1
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 18:31:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u59-v6sor322662plb.14.2018.02.05.18.31.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Feb 2018 18:31:06 -0800 (PST)
Date: Tue, 6 Feb 2018 11:31:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug
 198617] New: zswap causing random applications to crash)
Message-ID: <20180206023100.GA462@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
 <20180203013455.GA739@jagdpanzerIV>
 <CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
 <20180205013758.GA648@jagdpanzerIV>
 <87d11j4pdy.fsf@yhuang-dev.intel.com>
 <20180205123947.GA426@jagdpanzerIV>
 <20180205162428.99efbedb5a6e19bee19ba954@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180205162428.99efbedb5a6e19bee19ba954@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, huang ying <huang.ying.caritas@gmail.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On (02/05/18 16:24), Andrew Morton wrote:
> On Mon, 5 Feb 2018 21:39:47 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> 
> > > ---------------------------------8<-------------------------------
> > > From 4c52d531680f91572ebc6f4525a018e32a934ef0 Mon Sep 17 00:00:00 2001
> > > From: Huang Ying <huang.ying.caritas@gmail.com>
> > > Date: Mon, 5 Feb 2018 19:27:43 +0800
> > > Subject: [PATCH] fontswap thp fix
> > 
> > Seems to be fixing the problem on my x86 box. Executed several tests, no
> > crashes were observed. Can run more tests tomorrow.
> 
> Thanks.  I queued this for 4.16 with a cc:stable and a Fixes:
> bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
> out").
> 
> Can we please have a changelog ;)

Thanks!

Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
