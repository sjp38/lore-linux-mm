Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9084C6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 11:35:34 -0500 (EST)
Message-ID: <4F22D236.4@redhat.com>
Date: Fri, 27 Jan 2012 11:35:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com> <20120126145914.58619765@cuia.bos.redhat.com> <CAJd=RBB=MDiYLVSYJj8d8NfBZp+OU0Lf3-W5+xZUqj0J1JA4cQ@mail.gmail.com>
In-Reply-To: <CAJd=RBB=MDiYLVSYJj8d8NfBZp+OU0Lf3-W5+xZUqj0J1JA4cQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>

On 01/27/2012 04:13 AM, Hillf Danton wrote:

>> @@ -1195,7 +1195,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>                         BUG();
>>                 }
>>
>> -               if (!order)
>> +               if (!sc->order || !(sc->reclaim_mode&  RECLAIM_MODE_LUMPYRECLAIM))
>>                         continue;
>>
> Just a tiny advice 8-)
>
> mind to move checking lumpy reclaim out of the loop,
> something like

Hehe, I made the change the way it is on request
of Mel Gorman :)

I don't particularly care either way and will be
happy to make the code whichever way people prefer.

Just let me know.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
