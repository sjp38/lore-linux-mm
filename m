Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ECFE6B03B5
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:50:43 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v34so58808950iov.22
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 23:50:43 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i189si5382229pfb.162.2017.04.19.23.50.41
        for <linux-mm@kvack.org>;
        Wed, 19 Apr 2017 23:50:42 -0700 (PDT)
Date: Thu, 20 Apr 2017 15:50:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170420065028.GA3847@bbox>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
 <20170419060237.GA1636@bbox>
 <20170419115125.GA27790@bombadil.infradead.org>
 <20170420014542.GA542@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170420014542.GA542@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Apr 20, 2017 at 10:45:42AM +0900, Sergey Senozhatsky wrote:
> On (04/19/17 04:51), Matthew Wilcox wrote:
> [..]
> > > > > Another approach is the API does normal thing for non-aligned prefix and
> > > > > tail space and fast thing for aligned space.
> > > > > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > > > > address.
> > 
> > Why not just use memcpy()?  Is copy_page() significantly faster than
> > memcpy() for a PAGE_SIZE amount of data?
> 
> that's a good point.
> 
> I was going to ask yesterday - do we even need copy_page()? arch that
> provides well optimized copy_page() quite likely provides somewhat
> equally optimized memcpy(). so may be copy_page() is not even needed?

I don't know.

Just I found https://download.samba.org/pub/paulus/ols-2003-presentation.pdf
and heard https://lkml.org/lkml/2017/4/10/1270.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
