Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AB7CE6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 10:37:15 -0500 (EST)
Message-ID: <4ECA702B.5050908@redhat.com>
Date: Mon, 21 Nov 2011 10:37:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Revert "vmscan: abort reclaim/compaction if compaction
 can proceed"
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321732460-14155-8-git-send-email-aarcange@redhat.com> <20111121130915.GF19415@suse.de>
In-Reply-To: <20111121130915.GF19415@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On 11/21/2011 08:09 AM, Mel Gorman wrote:
> On Sat, Nov 19, 2011 at 08:54:19PM +0100, Andrea Arcangeli wrote:
>> This reverts commit e0c23279c9f800c403f37511484d9014ac83adec.
>>
>> If reclaim runs with an high order allocation, it means compaction
>> failed. That means something went wrong with compaction so we can't
>> stop reclaim too. We can't assume it failed and was deferred because
>> of the too low watermarks in compaction_suitable only, it may have
>> failed for other reasons.
>>
>
> When Rik was testing with THP enabled, he found that there was way
> too much memory free on his machine.

Agreed, without these patches, I saw up to about 4GB
of my 12GB memory being freed by pageout activity,
despite the programs in my system only taking about
10GB anonymous memory.

Needless to say, this completely killed system
performance, by constantly pushing everything into
swap and keeping 10-30% of memory free constantly.

This revert makes no sense at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
