Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 22BB8830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:20:55 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id kf7so10547844obb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:20:55 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id cm7si13044140oeb.87.2016.02.18.17.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 17:20:54 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id xk3so95438609obc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:20:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160218092926.083ca007@gandalf.local.home>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160218092926.083ca007@gandalf.local.home>
Date: Fri, 19 Feb 2016 10:20:54 +0900
Message-ID: <CAAmzW4O=S7YYGdtyGt181x72S=G5pxYChGKjPWXWRkjFBSFkrA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-18 23:29 GMT+09:00 Steven Rostedt <rostedt@goodmis.org>:
> On Mon, 15 Feb 2016 12:04:50 +0900
> js1304@gmail.com wrote:
>
>
>> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
>> index 534249c..fd6d9a5 100644
>> --- a/include/linux/page_ref.h
>> +++ b/include/linux/page_ref.h
>> @@ -1,6 +1,54 @@
>>  #include <linux/atomic.h>
>>  #include <linux/mm_types.h>
>>  #include <linux/page-flags.h>
>> +#include <linux/tracepoint-defs.h>
>> +
>> +extern struct tracepoint __tracepoint_page_ref_set;
>> +extern struct tracepoint __tracepoint_page_ref_mod;
>> +extern struct tracepoint __tracepoint_page_ref_mod_and_test;
>> +extern struct tracepoint __tracepoint_page_ref_mod_and_return;
>> +extern struct tracepoint __tracepoint_page_ref_mod_unless;
>> +extern struct tracepoint __tracepoint_page_ref_freeze;
>> +extern struct tracepoint __tracepoint_page_ref_unfreeze;
>> +
>> +#ifdef CONFIG_DEBUG_PAGE_REF
>
> Please add a comment here. Something to the effect of:

Okay!

> /*
>  * Ideally we would want to use the trace_<tracepoint>_enabled() helper
>  * functions. But due to include header file issues, that is not
>  * feasible. Instead we have to open code the static key functions.
>  *
>  * See trace_##name##_enabled(void) in include/linux/tracepoint.h
>  */
>
> I may have to work on something that lets these helpers be defined in
> headers. I have some ideas on how to do that. But for now, this
> solution is fine.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
