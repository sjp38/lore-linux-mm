Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6E86B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 00:40:39 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so186921353pgd.7
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:40:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z43si14569294plh.221.2017.01.22.21.40.37
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 21:40:38 -0800 (PST)
Date: Mon, 23 Jan 2017 14:40:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170123054034.GA12327@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
 <20170123053056.GB2327@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170123053056.GB2327@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Chulmin Kim <cmlaika.kim@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Jan 23, 2017 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
> On (01/23/17 14:22), Minchan Kim wrote:
> [..]
> > > Anyway, I will let you know the situation when it gets more clear.
> > 
> > Yeb, Thanks.
> > 
> > Perhaps, did you tried flush page before the writing?
> > I think arm64 have no d-cache alising problem but worth to try it.
> > Who knows :)
> 
> I thought that flush_dcache_page() is only for cases when we write
> to page (store that makes pages dirty), isn't it?

I think we need both because to see recent stores done by the user.
I'm not sure it should be done by block device driver rather than
page cache. Anyway, brd added it so worth to try it, I thought. :)

Thanks.

http://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=c2572f2b4ffc27ba79211aceee3bef53a59bb5cd


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
