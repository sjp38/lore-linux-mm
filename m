Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 906B86B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 19:31:50 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b24so276914pls.15
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 16:31:50 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g23-v6si3082523pli.195.2018.02.05.16.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 16:31:49 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug 198617] New: zswap causing random applications to crash)
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org>
	<20180203013455.GA739@jagdpanzerIV>
	<CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
	<20180205013758.GA648@jagdpanzerIV>
	<87d11j4pdy.fsf@yhuang-dev.intel.com>
	<20180205123947.GA426@jagdpanzerIV>
	<20180205162428.99efbedb5a6e19bee19ba954@linux-foundation.org>
Date: Tue, 06 Feb 2018 08:31:46 +0800
In-Reply-To: <20180205162428.99efbedb5a6e19bee19ba954@linux-foundation.org>
	(Andrew Morton's message of "Mon, 5 Feb 2018 16:24:28 -0800")
Message-ID: <87zi4n2c25.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, huang ying <huang.ying.caritas@gmail.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 5 Feb 2018 21:39:47 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
>
>> > ---------------------------------8<-------------------------------
>> > From 4c52d531680f91572ebc6f4525a018e32a934ef0 Mon Sep 17 00:00:00 2001
>> > From: Huang Ying <huang.ying.caritas@gmail.com>
>> > Date: Mon, 5 Feb 2018 19:27:43 +0800
>> > Subject: [PATCH] fontswap thp fix
>> 
>> Seems to be fixing the problem on my x86 box. Executed several tests, no
>> crashes were observed. Can run more tests tomorrow.
>
> Thanks.  I queued this for 4.16 with a cc:stable and a Fixes:
> bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
> out").
>
> Can we please have a changelog ;)

Sure!  I will send out today.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
