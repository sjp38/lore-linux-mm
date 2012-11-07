Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6EF466B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:43:48 -0500 (EST)
Message-ID: <509A4A00.1040602@redhat.com>
Date: Wed, 07 Nov 2012 06:46:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/19] mm: numa: Add fault driven placement and migration
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-16-git-send-email-mgorman@suse.de> <509967D9.7050706@redhat.com> <20121107104940.GU8218@suse.de>
In-Reply-To: <20121107104940.GU8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/07/2012 05:49 AM, Mel Gorman wrote:
> On Tue, Nov 06, 2012 at 02:41:13PM -0500, Rik van Riel wrote:
>> On 11/06/2012 04:14 AM, Mel Gorman wrote:

>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>
>> Excellent basis for implementing a smarter NUMA
>> policy.
>>
>> Not sure if such a policy should be implemented
>> as a replacement for this patch, or on top of it...
>>
>
> I'm expecting on top of it.

In that case:

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
