Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0B556B027E
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:19:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so12668324pfg.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:19:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a74si9403082pfe.391.2017.12.18.04.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:19:28 -0800 (PST)
Date: Mon, 18 Dec 2017 04:19:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] lockdep: Print number of locks held by running tasks.
Message-ID: <20171218121925.GA22866@bombadil.infradead.org>
References: <1513598995-4385-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513598995-4385-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzkaller@googlegroups.com, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Dec 18, 2017 at 09:09:55PM +0900, Tetsuo Handa wrote:
>  		 */
> -		if (p->state == TASK_RUNNING && p != current)
> +		if (p->state == TASK_RUNNING && p != current) {
> +			const int depth = p->lockdep_depth;

READ_ONCE()?

> +			if (depth)
> +				printk("%d lock%s held by %s/%d:\n",
> +				       depth, depth > 1 ? "s" : "", p->comm,
> +				       task_pid_nr(p));
>  			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
