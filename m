Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 46BFD6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:03:31 -0400 (EDT)
Received: by pddu5 with SMTP id u5so39807608pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:03:31 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id v4si3982445pbs.198.2015.07.07.08.03.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:03:30 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so127293477pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:03:29 -0700 (PDT)
Date: Wed, 8 Jul 2015 00:02:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 5/7] zsmalloc/zram: introduce zs_pool_stats api
Message-ID: <20150707150239.GD1450@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-6-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707133638.GB3898@blaptop>
 <20150707143256.GB1450@swordfish>
 <20150707144845.GB23003@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707144845.GB23003@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/07/15 23:48), Minchan Kim wrote:
[..]
> I have been used white space.
> As well, when I look at current code under mm which I'm getting used,
> almost everything use just white space.
> 

OK, don't want to engage into a meaningless discussion here.
I'll rollback those hunks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
