Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAB2D6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:15:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r88so15897212pfi.23
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 23:15:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q15sor4206599pgv.244.2017.12.19.23.15.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 23:15:05 -0800 (PST)
Date: Wed, 20 Dec 2017 16:15:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220071500.GA11774@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219155815.GC2787@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Aliaksei Karaliou <akaraliou.dev@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi,

On (12/19/17 16:58), Michal Hocko wrote:
[..]
> > we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
> > don't free any objects from that path. just move them around within their
> > size classes - to consolidate objects and to, may be, free unused pages
> > [but we first need to make them "unused"]. it's not a mandatory thing for
> > zsmalloc, we are just trying to be nice.
> 
> OK, it smells like an abuse of the API

we don't use shrinker callback to "just reduce the internal fragmentation".
the only reason we do de-fragmentation is to release the pages. if we see
that defragmentation is going to be a useless exercise and we are not going
to free pages, we just skip that class.

so at the end it's - the kernel asks us to shrink, we are trying to shrink
[release unneeded pages].

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
