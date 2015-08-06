Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B1358280245
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 10:30:29 -0400 (EDT)
Received: by pawu10 with SMTP id u10so64393740paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:30:29 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ng10si11705146pbc.253.2015.08.06.07.30.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 07:30:28 -0700 (PDT)
Received: by pawu10 with SMTP id u10so64393477paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:30:28 -0700 (PDT)
Date: Thu, 6 Aug 2015 23:29:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
Message-ID: <20150806142928.GD4292@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
 <20150617235205.GA3422@swordfish>
 <alpine.DEB.2.10.1506190850060.2584@hadrien>
 <20150806142131.GB4292@swordfish>
 <alpine.DEB.2.10.1508061626560.2343@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508061626560.2343@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (08/06/15 16:27), Julia Lawall wrote:
[..]
> > Julia, do you want to wait until these 3 patches will be merged to
> > Linus's tree (just to be on a safe side, so someone's tree (out of sync
> > with linux-next) will not go crazy)?
> 
> I think it would be safer.  Code may crash if the test is removed before
> the function can tolerate it.
> 

Agree. I'll re-up this thread later (once 4.3 merge window is closed).
Thank you.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
