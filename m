Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id AE1A26B0005
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:46:09 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id gc3so53657092obb.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:46:09 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id n10si7464162obi.78.2016.02.17.23.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 23:46:08 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id gc3so53656819obb.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:46:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160215201602.350d73fa@gandalf.local.home>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160215110741.7c0c5039@gandalf.local.home>
	<20160216004720.GA1782@js1304-P5Q-DELUXE>
	<20160215201602.350d73fa@gandalf.local.home>
Date: Thu, 18 Feb 2016 16:46:08 +0900
Message-ID: <CAAmzW4M3efu7T-PGtBwN=uNZ+bYpWCX+DBQK_nS149O9yyUu0w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

2016-02-16 10:16 GMT+09:00 Steven Rostedt <rostedt@goodmis.org>:
> On Tue, 16 Feb 2016 09:47:20 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> > They return true when CONFIG_TRACEPOINTS is configured in and the
>> > tracepoint is enabled, and false otherwise.
>>
>> This implementation is what you proposed before. Please refer below
>> link and source.
>>
>> https://lkml.org/lkml/2015/12/9/699
>> arch/x86/include/asm/msr.h
>
> That was a year ago, how am I suppose to remember ;-)

I think you are smart enough to remember. :)
I will add it on commit description on next spin.

>>
>> There is header file dependency problem between mm.h and tracepoint.h.
>> page_ref.h should be included in mm.h and tracepoint.h cannot
>> be included in this case.
>
> Ah, OK, I forgot about that. I'll take another look at it again.
>
> A lot happened since then, that's all a fog to me.

Okay. Please let me know result of another look.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
