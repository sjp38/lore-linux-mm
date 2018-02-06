Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 124096B0003
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 19:24:33 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id z83so128160wmc.5
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 16:24:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l16si7987095wrl.33.2018.02.05.16.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 16:24:31 -0800 (PST)
Date: Mon, 5 Feb 2018 16:24:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug
 198617] New: zswap causing random applications to crash)
Message-Id: <20180205162428.99efbedb5a6e19bee19ba954@linux-foundation.org>
In-Reply-To: <20180205123947.GA426@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
	<20180203013455.GA739@jagdpanzerIV>
	<CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
	<20180205013758.GA648@jagdpanzerIV>
	<87d11j4pdy.fsf@yhuang-dev.intel.com>
	<20180205123947.GA426@jagdpanzerIV>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, huang ying <huang.ying.caritas@gmail.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 5 Feb 2018 21:39:47 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> > ---------------------------------8<-------------------------------
> > From 4c52d531680f91572ebc6f4525a018e32a934ef0 Mon Sep 17 00:00:00 2001
> > From: Huang Ying <huang.ying.caritas@gmail.com>
> > Date: Mon, 5 Feb 2018 19:27:43 +0800
> > Subject: [PATCH] fontswap thp fix
> 
> Seems to be fixing the problem on my x86 box. Executed several tests, no
> crashes were observed. Can run more tests tomorrow.

Thanks.  I queued this for 4.16 with a cc:stable and a Fixes:
bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
out").

Can we please have a changelog ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
