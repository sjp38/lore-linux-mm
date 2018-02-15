Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30FF56B0011
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 22:46:16 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w19so3056936pgv.4
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 19:46:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i7si7129710pgq.209.2018.02.14.19.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 19:46:15 -0800 (PST)
Date: Wed, 14 Feb 2018 19:46:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180215034613.GC5775@bombadil.infradead.org>
References: <20180206060840.kj2u6jjmkuk3vie6@destitution>
 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
 <1517974845.4352.8.camel@gmail.com>
 <20180207065520.66f6gocvxlnxmkyv@destitution>
 <1518255240.31843.6.camel@gmail.com>
 <1518255352.31843.8.camel@gmail.com>
 <20180211225657.GA6778@dastard>
 <1518643669.6070.21.camel@gmail.com>
 <20180214215245.GI7000@dastard>
 <1518666178.6070.25.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518666178.6070.25.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Feb 15, 2018 at 08:42:58AM +0500, mikhail wrote:
> [101309.501428]  (sb_internal#2){.+.+}, at: [<00000000df1d676f>] xfs_trans_alloc+0xe2/0x120 [xfs]
> [101309.501465] 
>                 but task is already holding lock:
> [101309.501466]  (fs_reclaim){+.+.}, at: [<000000002ed6959d>] fs_reclaim_acquire.part.74+0x5/0x30
> [101309.501470] 
>                 which lock already depends on the new lock.

This one's an already-known mis-annotation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
