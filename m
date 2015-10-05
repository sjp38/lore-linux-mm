Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2E222440313
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 22:30:41 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so164510320pac.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 19:30:40 -0700 (PDT)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id j6si36489617pbq.56.2015.10.04.19.30.39
        for <linux-mm@kvack.org>;
        Sun, 04 Oct 2015 19:30:40 -0700 (PDT)
Date: Mon, 5 Oct 2015 10:30:00 +0800
From: Geliang Tang <geliangtang@163.com>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Message-ID: <20151005023000.GA1607@bogon>
References: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
 <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
 <20151005015055.GA8831@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151005015055.GA8831@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zij    lstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Leon Romanovsky <leon@leon.nu>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 04, 2015 at 06:50:55PM -0700, Davidlohr Bueso wrote:
> On Sun, 04 Oct 2015, Geliang Tang wrote:
> 
> >BUG_ON() already contain an unlikely compiler flag. Drop it.
> >
> >Signed-off-by: Geliang Tang <geliangtang@163.com>
> 
> Acked-by: Davidlohr Bueso <dave@stgolabs.net>
> 
> ... but I believe you do have some left:
> 
> drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > ivecs));
> drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > queue_max_integrity_segments(rq->q)));
> kernel/sched/core.c:    BUG_ON(unlikely(task_stack_end_corrupted(prev)));

Thanks for your review, the left have been sended out already in two other patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
