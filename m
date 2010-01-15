Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D84BC6B006A
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 12:23:17 -0500 (EST)
Received: by pxi5 with SMTP id 5so666952pxi.12
        for <linux-mm@kvack.org>; Fri, 15 Jan 2010 09:23:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100114141735.672B.A69D9226@jp.fujitsu.com>
References: <20100114084659.D713.A69D9226@jp.fujitsu.com>
	 <28c262361001132112i7f50fd66qcd24dc2ddb4d78d8@mail.gmail.com>
	 <20100114141735.672B.A69D9226@jp.fujitsu.com>
Date: Sat, 16 Jan 2010 02:23:16 +0900
Message-ID: <28c262361001150923l138f6805t22546887bf81b283@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, KOSAKI.

On Thu, Jan 14, 2010 at 2:18 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Well. zone->lock and zone->lru_lock should be not taked at the same time.
>>
>> I looked over the code since I am out of office.
>> I can't find any locking problem zone->lock and zone->lru_lock.
>> Do you know any locking order problem?
>> Could you explain it with call graph if you don't mind?
>>
>> I am out of office by tomorrow so I can't reply quickly.
>> Sorry for late reponse.
>
> This is not lock order issue. both zone->lock and zone->lru_lock are
> hotpath lock. then, same tame grabbing might cause performance impact.

Sorry for late response.

Your patch makes get_anon_scan_ratio of zoneinfo stale.
What you said about performance impact is effective when VM pressure high.
I think stale data is all right normally.
But when VM pressure is high and we want to see the information in zoneinfo(
this case is what you said), stale data is not a good, I think.

If it's not a strong argue, I want to use old get_scan_ratio
in get_anon_scan_ratio.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
