Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7A576B03AB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 21:45:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p80so50831510iop.16
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:45:40 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id 190si17064271itf.107.2017.04.19.18.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 18:45:40 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id d203so10185071iof.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:45:39 -0700 (PDT)
Date: Thu, 20 Apr 2017 10:45:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170420014542.GA542@jagdpanzerIV.localdomain>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
 <20170419060237.GA1636@bbox>
 <20170419115125.GA27790@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419115125.GA27790@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/19/17 04:51), Matthew Wilcox wrote:
[..]
> > > > Another approach is the API does normal thing for non-aligned prefix and
> > > > tail space and fast thing for aligned space.
> > > > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > > > address.
> 
> Why not just use memcpy()?  Is copy_page() significantly faster than
> memcpy() for a PAGE_SIZE amount of data?

that's a good point.

I was going to ask yesterday - do we even need copy_page()? arch that
provides well optimized copy_page() quite likely provides somewhat
equally optimized memcpy(). so may be copy_page() is not even needed?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
