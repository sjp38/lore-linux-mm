Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 44E6E900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 22:10:17 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so18888602pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:10:16 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id uy7si3444039pbc.246.2015.06.03.19.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 19:10:16 -0700 (PDT)
Received: by pdjm12 with SMTP id m12so19799483pdj.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:10:16 -0700 (PDT)
Date: Thu, 4 Jun 2015 11:10:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 01/10] zsmalloc: drop unused variable `nr_to_migrate'
Message-ID: <20150604021041.GA1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604020401.GB2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604020401.GB2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/04/15 11:04), Minchan Kim wrote:
> On Sat, May 30, 2015 at 12:05:19AM +0900, Sergey Senozhatsky wrote:
> > __zs_compact() does not use `nr_to_migrate', drop it.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 

Hello Minchan,

I will post a slightly reworked patchset later today.
thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
