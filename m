Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7VMrftx030509 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:53:41 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7VMreti020170 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:53:40 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7VMreQL028135 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:53:40 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3C000A829FLQ@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  1 Sep 2004 07:53:40 +0900 (JST)
Date: Wed, 01 Sep 2004 07:58:53 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator withou bitmap(2) [3/3]
In-reply-to: <1093970154.26660.4829.camel@nighthawk>
Message-id: <413502AD.90000@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4134573F.6060006@jp.fujitsu.com>
 <1093970154.26660.4829.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> On Tue, 2004-08-31 at 03:47, Hiroyuki KAMEZAWA wrote:
> 
>>"Does a page's buddy page exist or not ?" is checked by following.
>>------------------------
>>if ((address of buddy is smaller than that of page) &&
>>    (page->flags & PG_buddyend))
>>    this page has no buddy in this order.
>>------------------------
> 
> 
> What about the top-of-the-zone buddyend pages?  Are those covered
> elsewhere?

If zone is not aligned to MAX_ORDER, the top-of-the-zone buddyend pages
are marked as PG_buddyend.
I forget something ?



>>+static inline int page_is_buddy(struct page *page, int order)
>>+{
>>+	if (PagePrivate(page) &&
>>+	    (page_order(page) == order) &&
>>+	    !(page->flags & (1 << PG_reserved)) &&
> 
> 
> Please use a macro.
my mistake.

> 
>> 	if (order)
>> 		destroy_compound_page(page, order);
>>+
>> 	mask = (~0UL) << order;
>> 	page_idx = page - base;
> 
> 
> Repeat after me: No whitespace changes.  No whitespace changes.  No
> whitespace changes.
> 
very sorry ;(


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
