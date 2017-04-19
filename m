Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03EDA6B03A7
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:11:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j11so8566203pgn.9
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:11:46 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id u140si1405796pgb.67.2017.04.18.23.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 23:11:46 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id a188so2247130pfa.2
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:11:46 -0700 (PDT)
Date: Wed, 19 Apr 2017 15:11:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170419061149.GD2881@jagdpanzerIV.localdomain>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
 <20170418105641.GC558@jagdpanzerIV.localdomain>
 <20170418110632.GN22360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170418110632.GN22360@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/18/17 13:06), Michal Hocko wrote:
[..]
> > > copy_page is a performance sensitive function and I believe that we do
> > > those tricks exactly for this purpose.
> > 
> > a wild thought,
> > 
> > use
> > 	#define copy_page(to,from)	memcpy((to), (from), PAGE_SIZE)
> > 
> > when DEBUG_SLAB is set? so arch copy_page() (if provided by arch)
> > won't be affected otherwise.
> 
> SLAB is not guaranteed to provide page size aligned object AFAIR.

oh, if there are no guarantees for page_sized allocations regardless
the .config then agree, won't help.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
