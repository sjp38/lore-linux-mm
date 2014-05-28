Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 38B956B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 18:44:57 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id x48so12095811wes.36
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:44:56 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id e17si16903570wiw.8.2014.05.28.15.44.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 May 2014 15:44:55 -0700 (PDT)
Message-ID: <5386664A.5060304@zytor.com>
Date: Wed, 28 May 2014 15:42:18 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <1401260039-18189-1-git-send-email-minchan@kernel.org> <1401260039-18189-2-git-send-email-minchan@kernel.org> <20140528101401.43853563@gandalf.local.home> <f00f9b56-704d-4d03-ad0e-ec3ba2d122fd@email.android.com> <20140528221118.GN8554@dastard>
In-Reply-To: <20140528221118.GN8554@dastard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

On 05/28/2014 03:11 PM, Dave Chinner wrote:
> On Wed, May 28, 2014 at 07:23:23AM -0700, H. Peter Anvin wrote:
>> We tried for 4K on x86-64, too, for b quite a while as I recall.
>> The kernel stack is a one of the main costs for a thread.  I would
>> like to decouple struct thread_info from the kernel stack (PJ
>> Waskewicz was working on that before he left Intel) but that
>> doesn't buy us all that much.
>>
>> 8K additional per thread is a huge hit.  XFS has indeed always
>> been a canary, or troublespot, I suspect because it originally
>> came from another kernel where this was not an optimization
>> target.
> 
> <sigh>
> 
> Always blame XFS for stack usage problems.
> 
> Even when the reported problem is from IO to an ext4 filesystem.
> 

You were the one calling it a canary.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
