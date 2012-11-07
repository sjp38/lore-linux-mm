Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 20B0F6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:45:00 -0500 (EST)
Message-ID: <509A4A52.8000303@redhat.com>
Date: Wed, 07 Nov 2012 06:47:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/19] mm: numa: Add pte updates, hinting and migration
 stats
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-17-git-send-email-mgorman@suse.de> <50996B1A.7040601@redhat.com> <20121107105742.GV8218@suse.de>
In-Reply-To: <20121107105742.GV8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/07/2012 05:57 AM, Mel Gorman wrote:
> On Tue, Nov 06, 2012 at 02:55:06PM -0500, Rik van Riel wrote:
>> On 11/06/2012 04:14 AM, Mel Gorman wrote:

>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>
>> I'm skipping the ACKing of the policy patches, which
>> appear to be meant to be placeholders for a "real"
>> policy.
>
> I do expect the MORON policy to disappear or at least change so much it
> is not recognisable.

On the other hand, maybe it would be better to get
things at least into -mm, so the policy can be built
on top?

Just in case...

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
