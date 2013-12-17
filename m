Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6217A6B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 04:26:23 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so4775786qeb.40
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:26:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id s5si11356301qas.19.2013.12.17.01.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Dec 2013 01:26:22 -0800 (PST)
Date: Tue, 17 Dec 2013 10:26:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131217092611.GD21999@twins.programming.kicks-ass.net>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217092124.GV11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 09:21:25AM +0000, Mel Gorman wrote:
>  	if (sd) {
>  		id = cpumask_first(sched_domain_span(sd));
>  		size = cpumask_weight(sched_domain_span(sd));
> -		sd = sd->parent; /* sd_busy */
> +		busy_sd = sd->parent; /* sd_busy */
>  	}
> -	rcu_assign_pointer(per_cpu(sd_busy, cpu), sd);
> +	rcu_assign_pointer(per_cpu(sd_busy, cpu), busy_sd);

Argh, so much for paying attention :/

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
