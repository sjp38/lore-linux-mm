Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 003086B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 02:46:58 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id i129so13958328ioi.1
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 23:46:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z198sor4573532itb.85.2018.02.25.23.46.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 23:46:58 -0800 (PST)
Date: Mon, 26 Feb 2018 16:46:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180226074652.GB168047@rodete-desktop-imager.corp.google.com>
References: <20180210082321.17798-1-sergey.senozhatsky@gmail.com>
 <20180214055747.8420-1-sergey.senozhatsky@gmail.com>
 <20180220012429.GA186771@rodete-desktop-imager.corp.google.com>
 <20180226054927.GA12539@jagdpanzerIV>
 <20180226055804.GD112402@rodete-desktop-imager.corp.google.com>
 <20180226065035.GD12539@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226065035.GD12539@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Feb 26, 2018 at 03:50:35PM +0900, Sergey Senozhatsky wrote:
> On (02/26/18 14:58), Minchan Kim wrote:
> [..]
> > > Right. The changes are pretty trivial, that's why I kept then in
> > > 2 simple patches. Besides, I didn't want to mix zsmalloc and zram
> > > changes.
> > 
> > As I said earlier, it's not thing we usually do, at least, MM.
> > Anyway, I don't want to insist on it because it depends each
> > person's point of view what's the better for review, git-bisect.
> 
> Thanks :)
> 
> > > > 	size_t huge_size = _zs_huge_object(pool);
> > > > 	..
> > > > 	..
> > > > 	if (comp_size >= huge_size)
> > > > 		memcpy(dst, src, 4K);
> > > 
> > > Yes, can do. My plan was to keep it completely internally to zsmalloc.
> > > Who knows, it might become smart enough one day to do something more
> > > than just size comparison. Any reason you used that leading underscore
> > 
> > Let's do that in future if someone want it. :)
> 
> OK.
> 
> > > in _zs_huge_object()?
> > 
> > 
> > Nope. It's just typo. Let's think better name.
> > How about using zs_huge_size()?
> 
> hm, I think `huge_size' on it's own is a bit general and cryptic.
> zs_huge_object_size() or zs_huge_class_size()?

I wanted to use more general word to hide zsmalloc internal but
I realized it's really impossible to hide them all.
If so, let's use zs_huge_class_size and then let's add big fat
comment what the API represents in there.

Thanks, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
