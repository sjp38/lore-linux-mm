Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 816796B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:46:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so280330595pfy.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:46:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q26si208686pfi.106.2016.04.25.14.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:46:22 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:46:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zpool: use workqueue for zpool_destroy
Message-Id: <20160425144621.07f246158845fc08815c39dd@linux-foundation.org>
In-Reply-To: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
References: <CALZtONCDqBjL9TFmUEwuHaNU3n55k0VwbYWqW-9dODuNWyzkLQ@mail.gmail.com>
	<1461619210-10057-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Mon, 25 Apr 2016 17:20:10 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add a work_struct to struct zpool, and change zpool_destroy_pool to
> defer calling the pool implementation destroy.
> 
> The zsmalloc pool destroy function, which is one of the zpool
> implementations, may sleep during destruction of the pool.  However
> zswap, which uses zpool, may call zpool_destroy_pool from atomic
> context.  So we need to defer the call to the zpool implementation
> to destroy the pool.
> 
> This is essentially the same as Yu Zhao's proposed patch to zsmalloc,
> but moved to zpool.

OK, but the refrain remains the same: what are the runtime effects of
the change?  Are real people in real worlds seeing scary kernel
warnings?  Deadlocks?

This info is needed so that I and others can decide which kernel
version(s) should be patched.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
