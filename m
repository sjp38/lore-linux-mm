Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00FC36B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 11:12:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 68so47359817itg.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 08:12:18 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id z64si17358609itg.75.2017.03.01.08.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 08:12:18 -0800 (PST)
Date: Wed, 1 Mar 2017 17:12:20 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170301161220.GP6515@twins.programming.kicks-ass.net>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
 <20170301154659.GL6515@twins.programming.kicks-ass.net>
 <20170301160529.GI11730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301160529.GI11730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nikolay Borisov <nborisov@suse.com>, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed, Mar 01, 2017 at 05:05:30PM +0100, Michal Hocko wrote:
> Anyway, does the following help?

> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 47e4f82380e4..d5386ad7ed3f 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -47,6 +47,7 @@
>  #include <linux/kmemcheck.h>
>  #include <linux/random.h>
>  #include <linux/jhash.h>
> +#include <linux/sched.h>

No, Ingo moved that to linux/sched/mm.h in tip/master, which was the
problem.

But I think this needs to go to Linus in this cycle, right? In which
case Ingo gets to sort the fallout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
