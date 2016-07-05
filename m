Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 709F46B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:30:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so420752066pfa.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:30:26 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id n84si1320022pfj.141.2016.07.04.18.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:30:25 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id dx3so332451pab.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:30:25 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:30:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 4/8] mm/zsmalloc: use class->objs_per_zspage to get
 num of max objects
Message-ID: <20160705013030.GE459@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-4-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-4-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
> num of max objects in zspage is stored in each size_class now.
> So there is no need to re-calculate it.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
