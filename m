Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF9A6B0012
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:58:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8so7481295pfh.13
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:58:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62-v6sor93331ply.43.2018.03.13.06.58.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 06:58:24 -0700 (PDT)
Date: Tue, 13 Mar 2018 22:58:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 2/2] zram: drop max_zpage_size and use
 zs_huge_class_size()
Message-ID: <20180313135815.GA96381@rodete-laptop-imager.corp.google.com>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
 <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
 <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
 <20180313102437.GA5114@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313102437.GA5114@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Tue, Mar 13, 2018 at 07:24:37PM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (03/13/18 18:02), Minchan Kim wrote:
> > Sorry for being late.
> > I love this patchset! Just a minor below.
> 
> :)
> 
> [..]
> > > +	if (!huge_class_size)
> > > +		huge_class_size = zs_huge_class_size();
> > 
> > If it is static, we can do this in zram_init? I believe it's more readable in that
> > it's never changed betweens zram instances.
> 
> We need to have at least one pool, because pool decides where the
> watermark is. At zram_init() stage we don't have a pool yet. We
> zs_create_pool() in zram_meta_alloc() so that's why I put
> zs_huge_class_size() there. I'm not in love with it, but that's
> the only place where we can have it.

Fair enough. Then what happens if client calls zs_huge_class_size
without creating zs_create_pool?
I think we should make zs_huge_class_size has a zs_pool as argument.
