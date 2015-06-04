Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 475EF900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 22:04:08 -0400 (EDT)
Received: by padj3 with SMTP id j3so18894523pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:04:07 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id o6si3489548pdn.123.2015.06.03.19.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 19:04:07 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so18793062pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:04:07 -0700 (PDT)
Date: Thu, 4 Jun 2015 11:04:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 01/10] zsmalloc: drop unused variable `nr_to_migrate'
Message-ID: <20150604020401.GB2241@blaptop>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-2-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432911928-14654-2-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sat, May 30, 2015 at 12:05:19AM +0900, Sergey Senozhatsky wrote:
> __zs_compact() does not use `nr_to_migrate', drop it.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
