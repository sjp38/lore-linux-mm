Message-ID: <492BFE6F.5090902@redhat.com>
Date: Tue, 25 Nov 2008 08:32:31 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
References: <20081124145057.4211bd46@bree.surriel.com> <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> Sometimes the VM spends the first few priority rounds rotating back
>> referenced pages and submitting IO.  Once we get to a lower priority,
>> sometimes the VM ends up freeing way too many pages.
>>
>> The fix is relatively simple: in shrink_zone() we can check how many
>> pages we have already freed, direct reclaim tasks break out of the
>> scanning loop if they have already freed enough pages and have reached
>> a lower priority level.
>>
>> However, in order to do this we do need to know how many pages we already
>> freed, so move nr_reclaimed into scan_control.
>>
>> Signed-off-by: Rik van Riel <riel@redhat.com>
>> ---
>> Kosaki, this should address the zone scanning pressure issue.
> 
> hmmmm. I still don't like the behavior when priority==DEF_PRIORITY.
> but I also should explain by code and benchmark.

Well, the behaviour when priority==DEF_PRIORITY is the
same as the kernel's behaviour without the patch...

> therefore, I'll try to mesure this patch in this week.

Looking forward to it.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
