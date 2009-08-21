Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 777F46B007E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:14:18 -0400 (EDT)
Received: by ywh41 with SMTP id 41so1100018ywh.23
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:14:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A8C98DD.9030500@redhat.com>
References: <20090820085544.faed1ca4.minchan.kim@barrios-desktop>
	 <4A8C98DD.9030500@redhat.com>
Date: Fri, 21 Aug 2009 20:19:02 +0900
Message-ID: <2f11576a0908210419u2feadeaxc40ffda1cd7f6b2d@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix to infinite churning of mlocked page
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

2009/8/20 Rik van Riel <riel@redhat.com>:
> Minchan Kim wrote:
>>
>> Mlocked page might lost the isolatation race.
>> It cause the page to clear PG_mlocked while it remains
>> in VM_LOCKED vma. It means it can be put [in]active list.
>> We can rescue it by try_to_unmap in shrink_page_list.
>>
>> But now, As Wu Fengguang pointed out, vmscan have a bug.
>> If the page has PG_referenced, it can't reach try_to_unmap
>> in shrink_page_list but put into active list. If the page
>> is referenced repeatedly, it can remain [in]active list
>> without moving unevictable list.
>>
>> This patch can fix it.
>>
>> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: KOSAKI Motohiro <<kosaki.motohiro@jp.fujitsu.com>
>> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
>> Cc: Rik van Riel <riel@redhat.com>
>
> Acked-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
