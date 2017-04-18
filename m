Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3DB96B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 07:06:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x61so18473084wrb.8
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 04:06:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16si144138wma.151.2017.04.18.04.06.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 04:06:36 -0700 (PDT)
Date: Tue, 18 Apr 2017 13:06:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418110632.GN22360@dhcp22.suse.cz>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
 <20170418105641.GC558@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170418105641.GC558@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue 18-04-17 19:56:41, Sergey Senozhatsky wrote:
> On (04/18/17 09:33), Michal Hocko wrote:
> [..]
> > > Another approach is the API does normal thing for non-aligned prefix and
> > > tail space and fast thing for aligned space.
> > > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > > address.
> > 
> > copy_page is a performance sensitive function and I believe that we do
> > those tricks exactly for this purpose.
> 
> a wild thought,
> 
> use
> 	#define copy_page(to,from)	memcpy((to), (from), PAGE_SIZE)
> 
> when DEBUG_SLAB is set? so arch copy_page() (if provided by arch)
> won't be affected otherwise.

Wouldn't this just paper over bugs? SLAB is not guaranteed to provide
page size aligned object AFAIR.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
