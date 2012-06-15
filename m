Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B7FB46B0068
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:52:40 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3089345ggm.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:52:39 -0700 (PDT)
Message-ID: <4FDB5A42.9020707@gmail.com>
Date: Fri, 15 Jun 2012 11:52:34 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds pages
 to the buddy allocator again
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com> <4FDAE1F0.4030708@kernel.org>
In-Reply-To: <4FDAE1F0.4030708@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

(6/15/12 3:19 AM), Minchan Kim wrote:
> On 06/15/2012 01:16 AM, kosaki.motohiro@gmail.com wrote:
>
>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>
>> commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
>> to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
>> another miuse still exist.
>>
>> This patch fixes it.
>>
>> Cc: David Rientjes<rientjes@google.com>
>> Cc: Mel Gorman<mel@csn.ul.ie>
>> Cc: Johannes Weiner<hannes@cmpxchg.org>
>> Cc: Minchan Kim<minchan.kim@gmail.com>
>> Cc: Wu Fengguang<fengguang.wu@intel.com>
>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Rik van Riel<riel@redhat.com>
>> Cc: Andrew Morton<akpm@linux-foundation.org>
>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>
> Reviewed-by: Minchan Kim<minchan@kernel.org>
>
> Just nitpick.
> Personally, I want to fix it follwing as
> It's more simple and reduce vulnerable error in future.
>
> If you mind, go ahead with your version. I am not against with it, either.

I don't like your version because free_pcppages_bulk() can be called from
free_pages() hotpath. then, i wouldn't like to put a branch if we can avoid it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
