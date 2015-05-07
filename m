Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E5EA16B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 09:01:31 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so158461294igb.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 06:01:31 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0221.hostedemail.com. [216.40.44.221])
        by mx.google.com with ESMTP id c101si1407922iod.46.2015.05.07.06.01.30
        for <linux-mm@kvack.org>;
        Thu, 07 May 2015 06:01:30 -0700 (PDT)
Date: Thu, 7 May 2015 09:01:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 3/3] tracing: add trace event for memory-failure
Message-ID: <20150507090127.34a7f93f@gandalf.local.home>
In-Reply-To: <1430998681-24953-4-git-send-email-xiexiuqi@huawei.com>
References: <1430998681-24953-1-git-send-email-xiexiuqi@huawei.com>
	<1430998681-24953-4-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, mingo@redhat.com, akpm@linux-foundation.org, gong.chen@linux.intel.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On Thu, 7 May 2015 19:38:01 +0800
Xie XiuQi <xiexiuqi@huawei.com> wrote:

> +	TP_printk("pfn %#lx: recovery action for %s: %s",

I checked the libtraceevent code, and %# is handled.

-- Steve

> +		__entry->pfn,
> +		__print_symbolic(__entry->type, MF_PAGE_TYPE),
> +		__print_symbolic(__entry->result, MF_ACTION_RESULT)
> +	)
> +);
> +#endif /* CONFIG_MEMORY_FAILURE */
>  #endif /* _TRACE_HW_EVENT_MC_H */
>  
>  /* This part must be outside protection */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
