Received: from m7.gw.fujitsu.co.jp ([10.0.50.77]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7O0AcJB009350 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:10:38 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7O0AcsA013636 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:10:38 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7O0AbwE028668 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:10:37 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2X00JAACHOMH@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 09:10:37 +0900 (JST)
Date: Tue, 24 Aug 2004 09:15:47 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
In-reply-to: <1093275800.3153.825.camel@nighthawk>
Message-id: <412A88B3.7010705@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <1093275800.3153.825.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi

Thanks for comments.
I'd like to be more carefull about white spaces.

I'm now writing a new patch with detailed descriptions and
a few of additional range checks on 2.6.8.1-mm4.
This new one is running on both i386 and IA64 now.
(The previous patch cannot run on my IA64 ;( )

Thanks
Kame


Dave Hansen wrote:

> A few tiny, cosmetic comments on the patch itself:
> 
> 
>> }
>> 
>>+
>>+
>>+
>> #endif         /* CONFIG_HUGETLB_PAGE */
>> 
> 
> 
> Be careful about adding whitespace like that
> 
> 
>> /*
>>+ *     indicates page's order in freelist
>>+ *      order is recorded in inveterd manner.
>>+ */
> 
> 
> The comments around there tend to use a space instead of a tab in
> comments like this:
> /*
>  * foo
>  */
> 
> patch 2:
> 
>>                area = zone->free_area + current_order;
>>                if (list_empty(&area->free_list))
>>                        continue;
>>-
>>                page = list_entry(area->free_list.next, struct page, lru);
>>                list_del(&page->lru);
> 
> 
> More whitespace .
> 
> -- Dave
> 
> 


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
