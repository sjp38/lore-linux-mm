Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8D70B6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 15:53:52 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so72714517igb.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 12:53:52 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0169.hostedemail.com. [216.40.44.169])
        by mx.google.com with ESMTP id ga12si8934382igd.34.2015.04.20.12.53.51
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 12:53:51 -0700 (PDT)
Date: Mon, 20 Apr 2015 15:53:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 3/3] tracing: add trace event for memory-failure
Message-ID: <20150420155348.71ab777c@gandalf.local.home>
In-Reply-To: <1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
	<1429519480-11687-4-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, mingo@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, koct9i@gmail.com, hpa@linux.intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@amacapital.net, nasa4836@gmail.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On Mon, 20 Apr 2015 16:44:40 +0800
Xie XiuQi <xiexiuqi@huawei.com> wrote:

> RAS user space tools like rasdaemon which base on trace event, could
> receive mce error event, but no memory recovery result event. So, I
> want to add this event to make this scenario complete.
> 
> This patch add a event at ras group for memory-failure.
> 
> The output like below:
> #  tracer: nop
> #
> #  entries-in-buffer/entries-written: 2/2   #P:24
> #
> #                               _-----=> irqs-off
> #                              / _----=> need-resched
> #                             | / _---=> hardirq/softirq
> #                             || / _--=> preempt-depth
> #                             ||| /     delay
> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #               | |       |   ||||       |         |
>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: recovery action for free buddy page: Delayed
> 
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

Looks good to me.

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
