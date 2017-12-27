Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34BB86B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 02:10:20 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id y36so21206920plh.10
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 23:10:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor8963159pfj.92.2017.12.26.23.10.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Dec 2017 23:10:19 -0800 (PST)
Date: Wed, 27 Dec 2017 16:10:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zram: better utilization of zram swap space
Message-ID: <20171227071056.GA471@jagdpanzerIV>
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
 <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
 <20171227062946.GA11295@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227062946.GA11295@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gopi Sai Teja <gopi.st@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com

On (12/27/17 15:29), Minchan Kim wrote:
> On Fri, Dec 22, 2017 at 04:00:06PM +0530, Gopi Sai Teja wrote:
> > 75% of the PAGE_SIZE is not a correct threshold to store uncompressed
> 
> Please describe it in detail that why current threshold is bad in that
> memory efficiency point of view.
> 
> > pages in zs_page as this must be changed if the maximum pages stored
> > in zspage changes. Instead using zs classes, we can set the correct
> 
> Also, let's include the pharase Sergey pointed out in this description.
> 
> It's not a good idea that zram need to know allocator's implementation
> with harded value like 75%.

so I don't like that, basically, my work and my findings are
now submitted by someone else without even crediting my work.
not to mention that I like my commit message much better.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
