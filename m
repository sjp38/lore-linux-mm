Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8DE16B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:11:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so420114422pfa.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:11:50 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id i1si1097092pfg.263.2016.07.04.18.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:11:50 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id us13so16917454pab.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:11:50 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:11:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 6/8] mm/zsmalloc: keep comments consistent with code
Message-ID: <20160705011154.GB459@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-6-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-6-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
> some minor change of comments:
> 1). update zs_malloc(),zs_create_pool() function header
> 2). update "Usage of struct page fields"
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
