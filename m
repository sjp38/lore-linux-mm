Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 464F56B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:04:35 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so84552426pac.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:04:35 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id 184si36108575pfa.13.2016.02.21.18.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 18:04:34 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id e127so83997743pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:04:34 -0800 (PST)
Date: Mon, 22 Feb 2016 11:05:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222020547.GC488@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
 <20160222015912.GA488@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222015912.GA488@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 10:59), Sergey Senozhatsky wrote:
[..]
> > > > Having said that, I agree your claim that uncompressible pages
> > > > are pain. I want to handle the problem as multiple-swap apparoach.
> > > 
> > > zram is not just for swapping. as simple as that.
> > 
> > Yes, I mean if we have backing storage, we could mitigate the problem
> > like the mentioned approach. Otherwise, we should solve it in allocator
> > itself and you suggested the idea and I commented first step.
> > What's the problem, now?
> 
> well, I didn't say I have problems.
> so you want a backing device that will keep only 'bad compression'
> objects and use zsmalloc to keep there only 'good compression' objects?
> IOW, no huge classes in zsmalloc at all?

hm, in the worst case we can have _for example_ 80+% of writes to be 'bad
compression'. that turns zsmalloc into a 3rd wheel, and makes it almost
unneeded. hm, may be it's better for now to fix zsmalloc-zram pair.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
