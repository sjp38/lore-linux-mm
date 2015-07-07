Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D12C66B025C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:12:52 -0400 (EDT)
Received: by pddu5 with SMTP id u5so39940444pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:12:52 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id yw2si35072283pbc.95.2015.07.07.08.12.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:12:52 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so127426648pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:12:51 -0700 (PDT)
Date: Wed, 8 Jul 2015 00:12:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150707151204.GE1450@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707134445.GD3898@blaptop>
 <20150707144107.GC1450@swordfish>
 <20150707150143.GC23003@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707150143.GC23003@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/08/15 00:01), Minchan Kim wrote:
[..]
> > But why would we do this? Yes, it's kinda-sorta bad -- we were not
> > able to register zspool shrinker, so there will be no automatic
> > compaction... And that's it.
> > 
> > It does not affect zsmalloc/zram functionality by any means. Including
> > compaction itself -- user still has a way to compact zspool (manually).
> > And in some scenarios user will never even see automatic compaction in
> > action (assuming that there is a plenty of RAM available).
> > 
> > Can you explain your decision?
> 
> I don't think it would fail in *real practice*.
> Althout it might happen, what does zram could help in that cases?
> 

This argument depends on the current register_shrinker() implementation,
should some one add additional return branch there and it's done.

> If it were failed, it means there is already little memory on the system
> so zram could not be helpful for those environment.
> IOW, zram should be enabled earlier.
> 
> If you want it strongly, please reproduce such failing and prove that
> zram was helpful for the system.

No, thanks. I'll just remove it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
