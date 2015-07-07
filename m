Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE166B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:01:52 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so32541146pdb.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:01:51 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id kn10si34964232pbd.243.2015.07.07.08.01.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:01:51 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so127249631pdb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:01:50 -0700 (PDT)
Date: Wed, 8 Jul 2015 00:01:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150707150143.GC23003@blaptop>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707134445.GD3898@blaptop>
 <20150707144107.GC1450@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707144107.GC1450@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jul 07, 2015 at 11:41:07PM +0900, Sergey Senozhatsky wrote:
> On (07/07/15 22:44), Minchan Kim wrote:
> [..]
> > IMO, there is no value to maintain just in case of
> > failing register_shrinker in practice.
> > 
> > Let's remove shrinker_enabled and abort pool creation if shrinker register
> > is failed.
> 
> But why would we do this? Yes, it's kinda-sorta bad -- we were not
> able to register zspool shrinker, so there will be no automatic
> compaction... And that's it.
> 
> It does not affect zsmalloc/zram functionality by any means. Including
> compaction itself -- user still has a way to compact zspool (manually).
> And in some scenarios user will never even see automatic compaction in
> action (assuming that there is a plenty of RAM available).
> 
> Can you explain your decision?

I don't think it would fail in *real practice*.
Althout it might happen, what does zram could help in that cases?

If it were failed, it means there is already little memory on the system
so zram could not be helpful for those environment.
IOW, zram should be enabled earlier.

If you want it strongly, please reproduce such failing and prove that
zram was helpful for the system.

on that situation.



> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
