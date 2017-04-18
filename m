Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76E126B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 06:56:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a188so49761847pfa.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:56:39 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id d2si14078377plj.152.2017.04.18.03.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 03:56:38 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id g2so32766595pge.2
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:56:38 -0700 (PDT)
Date: Tue, 18 Apr 2017 19:56:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418105641.GC558@jagdpanzerIV.localdomain>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
 <20170418000319.GC21354@bbox>
 <20170418073307.GF22360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170418073307.GF22360@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/18/17 09:33), Michal Hocko wrote:
[..]
> > Another approach is the API does normal thing for non-aligned prefix and
> > tail space and fast thing for aligned space.
> > Otherwise, it would be happy if the API has WARN_ON non-page SIZE aligned
> > address.
> 
> copy_page is a performance sensitive function and I believe that we do
> those tricks exactly for this purpose.

a wild thought,

use
	#define copy_page(to,from)	memcpy((to), (from), PAGE_SIZE)

when DEBUG_SLAB is set? so arch copy_page() (if provided by arch)
won't be affected otherwise.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
