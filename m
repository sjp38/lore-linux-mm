Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6055B440313
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 21:51:23 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so94264689wic.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 18:51:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si13565648wiv.18.2015.10.04.18.51.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 Oct 2015 18:51:22 -0700 (PDT)
Date: Sun, 4 Oct 2015 18:50:55 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Message-ID: <20151005015055.GA8831@linux-uzut.site>
References: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
 <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Leon Romanovsky <leon@leon.nu>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 04 Oct 2015, Geliang Tang wrote:

>BUG_ON() already contain an unlikely compiler flag. Drop it.
>
>Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Davidlohr Bueso <dave@stgolabs.net>

... but I believe you do have some left:

drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > ivecs));
drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > queue_max_integrity_segments(rq->q)));
kernel/sched/core.c:    BUG_ON(unlikely(task_stack_end_corrupted(prev)));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
