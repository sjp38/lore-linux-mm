Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id F13916B0253
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:10:45 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id v14so12564318ykd.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:10:45 -0800 (PST)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id d188si8720976ybc.115.2016.01.20.07.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 07:10:45 -0800 (PST)
Received: by mail-yk0-x233.google.com with SMTP id k129so12664933yke.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:10:45 -0800 (PST)
Date: Wed, 20 Jan 2016 10:10:44 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs in
 shrink_slab
Message-ID: <20160120151044.GA5157@mtj.duckdns.org>
References: <569D06F8.4040209@redhat.com>
 <569E1010.2070806@I-love.SAKURA.ne.jp>
 <569E5287.4080503@redhat.com>
 <201601201923.DCC48978.FSHLOQtOVJFFOM@I-love.SAKURA.ne.jp>
 <201601202217.BEF43262.QOLFHOOJFVFtMS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601202217.BEF43262.QOLFHOOJFVFtMS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jiangshanlai@gmail.com, jstancek@redhat.com, linux-mm@kvack.org, ltp@lists.linux.it

On Wed, Jan 20, 2016 at 10:17:23PM +0900, Tetsuo Handa wrote:
> What happens if memory allocation requests from items using this workqueue
> got stuck due to OOM livelock? Are pending items in this workqueue cannot
> be processed because this workqueue was created without WQ_MEM_RECLAIM?

If something gets stuck due to OOM livelock, anything which tries to
allocate memory can hang.  That's why it's called a livelock.
WQ_MEM_RECLAIM or not wouldn't make any difference.

> I don't know whether accessing swap memory depends on this workqueue.
> But if disk driver depends on this workqueue for accessing swap partition
> on the disk, some event is looping inside memory allocator will result in
> unable to process disk I/O request for accessing swap partition on the disk?

What you're saying is too vauge for me to decipher exactly what you
have on mind.  Can you please elaborate?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
