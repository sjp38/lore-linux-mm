Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 185006B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 13:51:41 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so5812115qaq.39
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 10:51:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y1si1252179qal.136.2014.01.20.10.51.39
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 10:51:40 -0800 (PST)
Message-ID: <52DD7016.9080708@redhat.com>
Date: Mon, 20 Jan 2014 13:51:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] numa,sched: tracepoints for NUMA balancing active
 nodemask changes
References: <1389993129-28180-1-git-send-email-riel@redhat.com> <1389993129-28180-5-git-send-email-riel@redhat.com> <20140120165205.GJ31570@twins.programming.kicks-ass.net>
In-Reply-To: <20140120165205.GJ31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, mgorman@suse.de, mingo@redhat.com, Steven Rostedt <rostedt@goodmis.org>

On 01/20/2014 11:52 AM, Peter Zijlstra wrote:
> On Fri, Jan 17, 2014 at 04:12:06PM -0500, riel@redhat.com wrote:

>> +++ b/kernel/sched/fair.c
>> @@ -1300,10 +1300,14 @@ static void update_numa_active_node_mask(struct task_struct *p)
>>  		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
>>  			 numa_group->faults_from[task_faults_idx(nid, 1)];
>>  		if (!node_isset(nid, numa_group->active_nodes)) {
>> -			if (faults > max_faults * 4 / 10)
>> +			if (faults > max_faults * 4 / 10) {
>> +				trace_update_numa_active_nodes_mask(current->pid, numa_group->gid, nid, true, faults, max_faults);
> 
> While I think the tracepoint hookery is smart enough to avoid evaluating
> arguments when they're disabled, it might be best to simply pass:
> current and numa_group and do the dereference in fast_assign().
> 
> That said, this is the first and only numa tracepoint, I'm not sure why
> this qualifies and other metrics do not.

It's there because I needed it in development.

If you think it is not merge material, I would be comfortable
leaving it out.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
