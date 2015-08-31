Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3A49F6B0257
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:27:17 -0400 (EDT)
Received: by wicmc4 with SMTP id mc4so3957900wic.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:27:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si27303234wjz.123.2015.08.31.08.27.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 08:27:15 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm, compaction: export tracepoints status strings to
 userspace
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
 <20150831105538.2cf4b3ae@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E47252.7030201@suse.cz>
Date: Mon, 31 Aug 2015 17:27:14 +0200
MIME-Version: 1.0
In-Reply-To: <20150831105538.2cf4b3ae@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 08/31/2015 04:55 PM, Steven Rostedt wrote:
> On Thu, 27 Aug 2015 17:24:02 +0200
> Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> Some compaction tracepoints convert the integer return values to strings using
>> the compaction_status_string array. This works for in-kernel printing, but not
>> userspace trace printing of raw captured trace such as via trace-cmd report.
>>
>> This patch converts the private array to appropriate tracepoint macros that
>> result in proper userspace support.
>>
>> trace-cmd output before:
>> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
>>    zone=ffffffff81815d7a order=9 ret=
>>
>> after:
>> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
>>    zone=ffffffff81815d7a order=9 ret=partial
>>
>
> Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
