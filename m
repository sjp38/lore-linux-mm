Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ACE496B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 13:58:40 -0400 (EDT)
Message-ID: <4A787D84.2030207@redhat.com>
Date: Tue, 04 Aug 2009 14:27:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script
 for page-allocator-related ftrace events
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>	<1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
In-Reply-To: <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue,  4 Aug 2009 19:12:26 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
>> This patch adds a simple post-processing script for the page-allocator-related
>> trace events. It can be used to give an indication of who the most
>> allocator-intensive processes are and how often the zone lock was taken
>> during the tracing period. Example output looks like
>>
>> find-2840
>>  o pages allocd            = 1877
>>  o pages allocd under lock = 1817
>>  o pages freed directly    = 9
>>  o pcpu refills            = 1078
>>  o migrate fallbacks       = 48
>>    - fragmentation causing = 48
>>      - severe              = 46
>>      - moderate            = 2
>>    - changed migratetype   = 7
> 
> The usual way of accumulating and presenting such measurements is via
> /proc/vmstat.  How do we justify adding a completely new and different
> way of doing something which we already do?

Mel's tracing is more akin to BSD process accounting,
where these statistics are kept on a per-process basis.

Nothing in /proc allows us to see statistics on a per
process basis on process exit.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
