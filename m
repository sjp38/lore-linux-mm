Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id A47146B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 01:59:13 -0400 (EDT)
Received: by oign205 with SMTP id n205so25576147oig.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 22:59:13 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id xr13si627463oeb.42.2015.05.06.22.59.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 22:59:12 -0700 (PDT)
Message-ID: <554AFEE6.3060803@huawei.com>
Date: Thu, 7 May 2015 13:57:58 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/3] tracing: add trace event for memory-failure
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com> <5540BD13.1010408@huawei.com> <20150507011207.GC7745@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150507011207.GC7745@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On 2015/5/7 9:12, Naoya Horiguchi wrote:
> On Wed, Apr 29, 2015 at 07:14:27PM +0800, Xie XiuQi wrote:
>> Hi Naoya,
>>
>> Could you help to review and applied this series if possible.
> 
> Sorry for late response, I was offline for several days due to national
> holidays.

It doesn't matter, wish you have a good holiday ;-)

> 
> This patchset is good to me, but I'm not sure which path it should go through.
> Ordinarily, memory-failure patches go to linux-mm, but patch 3 depends on
> TRACE_DEFINE_ENUM patches, so this can go to linux-next directly, or go to
> linux-mm with depending patches.

TRACE_DEFINE_ENUM patches has been merged into mainline. I'll correct patch 3's typo
and rebase them on top of latest mainline in v5.

Thanks,
	Xie XiuQi

> 
> Steven, Andrew, which way do you like?
> 
> Thanks,
> Naoya Horiguchi
> 
>> Thanks,
>> Xie XiuQi
>>
>> On 2015/4/20 16:44, Xie XiuQi wrote:
>>> RAS user space tools like rasdaemon which base on trace event, could
>>> receive mce error event, but no memory recovery result event. So, I
>>> want to add this event to make this scenario complete.
>>>
>>> This patchset add a event at ras group for memory-failure.
>>>
>>> The output like below:
>>> #  tracer: nop
>>> #
>>> #  entries-in-buffer/entries-written: 2/2   #P:24
>>> #
>>> #                               _-----=> irqs-off
>>> #                              / _----=> need-resched
>>> #                             | / _---=> hardirq/softirq
>>> #                             || / _--=> preempt-depth
>>> #                             ||| /     delay
>>> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
>>> #               | |       |   ||||       |         |
>>>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: recovery action for free buddy page: Delayed
>>>
>>> --
>>> v3->v4:
>>>  - rebase on top of latest linux-next
>>>  - update comments as Naoya's suggestion
>>>  - add #ifdef CONFIG_MEMORY_FAILURE for this trace event
>>>  - change type of action_result's param 3 to enum
>>>
>>> v2->v3:
>>>  - rebase on top of linux-next
>>>  - based on Steven Rostedt's "tracing: Add TRACE_DEFINE_ENUM() macro
>>>    to map enums to their values" patch set v1.
>>>
>>> v1->v2:
>>>  - Comment update
>>>  - Just passing 'result' instead of 'action_name[result]',
>>>    suggested by Steve. And hard coded there because trace-cmd
>>>    and perf do not have a way to process enums.
>>>
>>> Xie XiuQi (3):
>>>   memory-failure: export page_type and action result
>>>   memory-failure: change type of action_result's param 3 to enum
>>>   tracing: add trace event for memory-failure
>>>
>>>  include/linux/mm.h      |  34 ++++++++++
>>>  include/ras/ras_event.h |  85 ++++++++++++++++++++++++
>>>  mm/memory-failure.c     | 172 ++++++++++++++++++++----------------------------
>>>  3 files changed, 190 insertions(+), 101 deletions(-)
>>>
>>
>> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
