Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A955A6B03A0
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 07:51:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z67so8365077itb.4
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 04:51:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s1si2368265pge.356.2017.04.19.04.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 04:51:29 -0700 (PDT)
Date: Wed, 19 Apr 2017 04:51:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170419115125.GA27790@bombadil.infradead.org>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
 <20170419060237.GA1636@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419060237.GA1636@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Apr 19, 2017 at 03:02:37PM +0900, Minchan Kim wrote:
> On Tue, Apr 18, 2017 at 09:33:07AM +0200, Michal Hocko wrote:
> > I do not follow. Why would you need kmap for something that is already
> > in the kernel space?
> 
> Because it can work with highmem pages.

That's copy_user_highpage().  If you want to define a new arch API
copy_highpage(), feel free to make a case for it ...

> > > Another approach is the API does normal thing for non-aligned prefix and
> > > tail space and fast thing for aligned space.
> > > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > > address.

Why not just use memcpy()?  Is copy_page() significantly faster than
memcpy() for a PAGE_SIZE amount of data?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
