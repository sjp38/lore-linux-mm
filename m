Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C987D6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:41:55 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so126991787pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:41:55 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id co3si35003717pad.233.2015.07.07.07.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 07:41:55 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so114352419pab.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:41:54 -0700 (PDT)
Date: Tue, 7 Jul 2015 23:41:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150707144107.GC1450@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707134445.GD3898@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707134445.GD3898@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/07/15 22:44), Minchan Kim wrote:
[..]
> IMO, there is no value to maintain just in case of
> failing register_shrinker in practice.
> 
> Let's remove shrinker_enabled and abort pool creation if shrinker register
> is failed.

But why would we do this? Yes, it's kinda-sorta bad -- we were not
able to register zspool shrinker, so there will be no automatic
compaction... And that's it.

It does not affect zsmalloc/zram functionality by any means. Including
compaction itself -- user still has a way to compact zspool (manually).
And in some scenarios user will never even see automatic compaction in
action (assuming that there is a plenty of RAM available).

Can you explain your decision?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
