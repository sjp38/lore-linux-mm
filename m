Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93FC16B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 00:49:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i11so5174136pgq.10
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 21:49:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l19sor1505917pgc.199.2018.02.25.21.49.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 21:49:32 -0800 (PST)
Date: Mon, 26 Feb 2018 14:49:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv3 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180226054927.GA12539@jagdpanzerIV>
References: <20180210082321.17798-1-sergey.senozhatsky@gmail.com>
 <20180214055747.8420-1-sergey.senozhatsky@gmail.com>
 <20180220012429.GA186771@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180220012429.GA186771@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/20/18 10:24), Minchan Kim wrote:
> Hi Sergey,

[..]

> Sorry for the long delay. I was horribly busy for a few weeks. ;-(

My turn to say "Sorry for the delay" :)

[..]
> I think it's simple enough. :)

Right. The changes are pretty trivial, that's why I kept then in
2 simple patches. Besides, I didn't want to mix zsmalloc and zram
changes.

> Can't zram ask to zsmalloc about what size is for hugeobject from?
> With that, zram can save the wartermark in itself and use it.
> What I mean is as follows,
> 
> zram:
> 	size_t huge_size = _zs_huge_object(pool);
> 	..
> 	..
> 	if (comp_size >= huge_size)
> 		memcpy(dst, src, 4K);

Yes, can do. My plan was to keep it completely internally to zsmalloc.
Who knows, it might become smart enough one day to do something more
than just size comparison. Any reason you used that leading underscore
in _zs_huge_object()?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
