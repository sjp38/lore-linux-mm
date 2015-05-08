Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5C54D6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 21:00:28 -0400 (EDT)
Received: by obcus9 with SMTP id us9so15261489obc.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 18:00:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id t10si2176928obg.42.2015.05.07.18.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 May 2015 18:00:27 -0700 (PDT)
Message-ID: <554C0A92.2080709@huawei.com>
Date: Fri, 8 May 2015 09:00:02 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3/3] tracing: add trace event for memory-failure
References: <1430998681-24953-1-git-send-email-xiexiuqi@huawei.com>	<1430998681-24953-4-git-send-email-xiexiuqi@huawei.com> <20150507090127.34a7f93f@gandalf.local.home>
In-Reply-To: <20150507090127.34a7f93f@gandalf.local.home>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: n-horiguchi@ah.jp.nec.com, mingo@redhat.com, akpm@linux-foundation.org, gong.chen@linux.intel.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On 2015/5/7 21:01, Steven Rostedt wrote:
> On Thu, 7 May 2015 19:38:01 +0800
> Xie XiuQi <xiexiuqi@huawei.com> wrote:
> 
>> +	TP_printk("pfn %#lx: recovery action for %s: %s",
> 
> I checked the libtraceevent code, and %# is handled.

Good, thank you!

> 
> -- Steve
> 
>> +		__entry->pfn,
>> +		__print_symbolic(__entry->type, MF_PAGE_TYPE),
>> +		__print_symbolic(__entry->result, MF_ACTION_RESULT)
>> +	)
>> +);
>> +#endif /* CONFIG_MEMORY_FAILURE */
>>  #endif /* _TRACE_HW_EVENT_MC_H */
>>  
>>  /* This part must be outside protection */
>>
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
