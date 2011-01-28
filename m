Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 65F998D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 15:55:37 -0500 (EST)
Message-ID: <4D432D2D.4020504@redhat.com>
Date: Fri, 28 Jan 2011 15:55:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com> <20110128103539.GA14669@csn.ul.ie> <20110128162831.GH16981@random.random> <20110128164624.GA23905@csn.ul.ie> <4D42F9E3.2010605@redhat.com> <20110128174644.GM16981@random.random> <4D430506.2070502@redhat.com> <20110128182407.GO16981@random.random> <4D431A47.90408@redhat.com> <20110128194542.GV16981@random.random>
In-Reply-To: <20110128194542.GV16981@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2011 02:45 PM, Andrea Arcangeli wrote:
> On Fri, Jan 28, 2011 at 02:34:31PM -0500, Rik van Riel wrote:
>> It will block at high+gap only when one zone has really
>> easily reclaimable memory, and another zone has difficult
>> to free memory.
>
> The other zone doesn't need to be difficult to free up. All ram in
> immediately freeable clean cache is the most common case there is. And
> it's more than enough to trigger the scenario in prev email.
>
>> That creates a free memory differential between the
>> easy to free and difficult to free memory zones.
>
> There's no difficult to free zone in this scenario.

In that case, every zone will go down to the low watermark
before kswapd is woken up.

At that point, kswapd will reclaim until every zone is at
the high watermark, and go back to sleep.

There is no "free up to high + gap" in your scenario.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
