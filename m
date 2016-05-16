Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23E9C828E1
	for <linux-mm@kvack.org>; Sun, 15 May 2016 21:19:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so269816716pac.1
        for <linux-mm@kvack.org>; Sun, 15 May 2016 18:19:43 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id q80si41792964pfi.230.2016.05.15.18.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 May 2016 18:19:42 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id gh9so13115989pac.0
        for <linux-mm@kvack.org>; Sun, 15 May 2016 18:19:42 -0700 (PDT)
Date: Mon, 16 May 2016 10:17:31 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 05/12] zsmalloc: use bit_spin_lock
Message-ID: <20160516011730.GA504@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462760433-32357-6-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/09/16 11:20), Minchan Kim wrote:
> 
> Use kernel standard bit spin-lock instead of custom mess. Even, it has
> a bug which doesn't disable preemption. The reason we don't have any
> problem is that we have used it during preemption disable section
> by class->lock spinlock. So no need to go to stable.
> 
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

good change.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
