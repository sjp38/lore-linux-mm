Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAD47828E5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 21:40:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so40351367pfs.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 18:40:55 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id o10si4502887paw.103.2016.06.08.18.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 18:40:54 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 62so1665446pfd.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 18:40:54 -0700 (PDT)
Date: Thu, 9 Jun 2016 10:40:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160609014052.GA655@swordfish>
References: <1464919731-13255-1-git-send-email-minchan@kernel.org>
 <20160603080141.GA490@swordfish>
 <20160603082336.GA18488@bbox>
 <20160603102432.GB586@swordfish>
 <20160607014340.GB26230@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160607014340.GB26230@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hello Minchan,

On (06/07/16 10:43), Minchan Kim wrote:
[..]
> > > It doesn't support per-zone stat which is important to show
> > > the fragmentation of the zone, for exmaple.
> > 
> > Ah, I see.
> > 
> > *just an idea*
> > 
> > may be zbud and z3fold folks will be interested as well, so may
> 
> First motivation of stat came from fragmentation problem from zsmalloc
> which caused by storing many thin zpages in a pageframe and across two
> pageframes while zswap limits the limitation by design.
> 
> Second motivation is zsmalloc can allocate page from HIGH/movable zones
> so I want to know how distribution zsmalloced pages is.
> However, zbud doesn't.

good points.
well, my "motivation" was "on 64-bit systems high zone is empty,
so those are zones below the high zone that we are interested in".

[..]
> > be more generic name and define... um, my head doesn't work toay..
> > ZALLOC... ZPOOLALLOC... hm.. I think you got the idea.
> 
> Having said that, generic name is better rather than zsmalloc. Thanks.
> I want to use *zspage* which is term from the beginning of zprojects. :)

thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
