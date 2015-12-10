Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DF65482F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:51:50 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id v187so24199516wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:51:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 21si14268wmn.45.2015.12.10.01.51.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 01:51:49 -0800 (PST)
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
 <20151210035128.GA7814@home.goodmis.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56694B32.9060504@suse.cz>
Date: Thu, 10 Dec 2015 10:51:46 +0100
MIME-Version: 1.0
In-Reply-To: <20151210035128.GA7814@home.goodmis.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Ingo Molnar <mingo@kernel.org>

On 12/10/2015 04:51 AM, Steven Rostedt wrote:
> I should have been Cc'd on this as I'm the maintainer of a few of the files
> here that is being modified.

Sorry about that.

>> --- a/include/linux/trace_events.h
>> +++ b/include/linux/trace_events.h
>> @@ -15,16 +15,6 @@ struct tracer;
>>   struct dentry;
>>   struct bpf_prog;
>>
>> -struct trace_print_flags {
>> -	unsigned long		mask;
>> -	const char		*name;
>> -};
>> -
>> -struct trace_print_flags_u64 {
>> -	unsigned long long	mask;
>> -	const char		*name;
>> -};
>> -
>
> Ingo took some patches from Andi Kleen that creates a tracepoint-defs.h file
> If anything, these should be moved there. That code is currently in tip.

Yeah I noticed that yesterday and seems like a good idea. Rasmus 
suggested types.h but these didn't seem general enough for that one. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
