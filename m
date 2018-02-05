Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47A2B6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 07:43:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m3so19850212pgd.20
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 04:43:29 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i14sor1271490pgp.145.2018.02.05.04.43.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Feb 2018 04:43:28 -0800 (PST)
Date: Mon, 5 Feb 2018 21:43:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug
 198617] New: zswap causing random applications to crash)
Message-ID: <20180205124323.GB426@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
 <20180203013455.GA739@jagdpanzerIV>
 <CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
 <20180205013758.GA648@jagdpanzerIV>
 <87d11j4pdy.fsf@yhuang-dev.intel.com>
 <20180205123947.GA426@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180205123947.GA426@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On (02/05/18 21:39), Sergey Senozhatsky wrote:
> > I have successfully reproduced the issue and find the problem.  The
> > following patch fix the issue for me, can you try it?
> 
> That was quick ;)
> 
> > ---------------------------------8<-------------------------------
> > From 4c52d531680f91572ebc6f4525a018e32a934ef0 Mon Sep 17 00:00:00 2001
> > From: Huang Ying <huang.ying.caritas@gmail.com>
> > Date: Mon, 5 Feb 2018 19:27:43 +0800
> > Subject: [PATCH] fontswap thp fix
> 
> Seems to be fixing the problem on my x86 box. Executed several tests, no
> crashes were observed. Can run more tests tomorrow.
> 
> 
> ============================================================================
> 
> Probably unrelated, but may be it is related: my X server used to hang
> sometimes (rarely) which I suspect was/is caused by nouveau driver. It,
> surprisingly, didn't hang this time around. Nouveau spitted a number
> of backtraces, but X server managed to survive it. Any chance that
> nouveau-X server thing was caused by THP?

No, wait. How could it be... I don't even use frontswap usually.
Sorry for the silly question.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
