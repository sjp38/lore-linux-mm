Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86685828E1
	for <linux-mm@kvack.org>; Sun, 15 May 2016 21:48:32 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so235294025pac.0
        for <linux-mm@kvack.org>; Sun, 15 May 2016 18:48:32 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id gs6si42266044pac.81.2016.05.15.18.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 May 2016 18:48:31 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id g132so14318459pfb.3
        for <linux-mm@kvack.org>; Sun, 15 May 2016 18:48:31 -0700 (PDT)
Date: Mon, 16 May 2016 10:48:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 06/12] zsmalloc: use accessor
Message-ID: <20160516014826.GB504@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462760433-32357-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/09/16 11:20), Minchan Kim wrote:
> Upcoming patch will change how to encode zspage meta so for easy review,
> this patch wraps code to access metadata as accessor.
> 
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
