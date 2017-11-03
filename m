Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 000F46B0069
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:55:01 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q81so7812698ioi.12
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:55:01 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0064.hostedemail.com. [216.40.44.64])
        by mx.google.com with ESMTPS id c124si5242218iof.254.2017.11.03.04.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 04:55:01 -0700 (PDT)
Date: Fri, 3 Nov 2017 07:54:56 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171103075456.15cd811e@vmware.local.home>
In-Reply-To: <20171103075404.14f9058a@vmware.local.home>
References: <20171102134515.6eef16de@gandalf.local.home>
	<82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
	<9f3bbbab-ef58-a2a6-d4c5-89e62ade34f8@nvidia.com>
	<20171103072121.3c2fd5ab@vmware.local.home>
	<20171103075404.14f9058a@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Fri, 3 Nov 2017 07:54:04 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> The new waiter gets set only if there isn't already a waiter *and*
> there is an owner that is not current (and with the printk_safe_enter I
> don't think that is even needed).
> 
> +				while (!READ_ONCE(console_waiter))
> +					cpu_relax();

I still need to fix the patch. I cut and pasted the bad version. This
should have been:

	while (READ_ONCE(console_waiter))
		cpu_relax();

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
