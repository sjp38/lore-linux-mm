Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 63AF86B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 20:54:04 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so174078952pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:54:04 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id gw3si11702344pac.117.2015.07.09.17.54.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 17:54:03 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so160367232pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:54:03 -0700 (PDT)
Date: Fri, 10 Jul 2015 09:54:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150710005407.GA584@swordfish>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436355113-12417-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150710004921.GA10230@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710004921.GA10230@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Minchan,

On (07/10/15 09:49), Minchan Kim wrote:
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Suggested-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> Thanks for great work!

Thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
