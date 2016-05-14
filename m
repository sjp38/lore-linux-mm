Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 051B06B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 22:39:37 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id yl2so172301205pac.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 19:39:36 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k4si2819490paw.171.2016.05.13.19.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 19:39:35 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id b66so2643332pfb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 19:39:35 -0700 (PDT)
Date: Sat, 14 May 2016 12:37:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160514033707.GA15615@swordfish>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
 <20160513065805.GB615@swordfish>
 <20160513070553.GC615@swordfish>
 <20160513072006.GA21484@bbox>
 <20160513080643.GE615@swordfish>
 <20160513230546.GA26763@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513230546.GA26763@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Minchan,

On (05/14/16 08:05), Minchan Kim wrote:
[..]
> > recompress:
> > 	compress
> > 	handle = zs_malloc FAST PATH
> > 
> > 	if (!handle) {
> > 		release stream
> > 		handle = zs_malloc SLOW PATH
> > 
> > 		<< my patch accounts SLOW PATH here >>
> > 
> > 		if (handle) {
> > 			num_recompress++  << NEW version accounts it here, only it was OK >>
> > 			goto recompress;
> > 		}
> > 
> > 		goto err;    << SLOW PATH is not accounted if SLOW PATH was unsuccessful
> > 	}
> > 
> 
> I got your point. You want to account every slow path and change
> the naming from num_recompress to something to show that slow path.

yes :)

> Sorry for catching your point too late. And I absolutely agree with you.
> I want to name it with 'writestall' like MM's allocstall. :)

no problem. 'writestall' is really good, that's the word I was looking
for.

> Now I saw you sent new version but I like your suggestion more.
> 
> I will send new verion by hand :)
> Thanks for the arguing. It was worth!

oh, thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
