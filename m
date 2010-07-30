Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4BF116B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 22:52:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6U2qfIW020958
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Fri, 30 Jul 2010 11:52:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F32E45DE51
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:52:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 101FE45DE50
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:52:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7BBDEF8005
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:52:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13F611DB804E
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:52:40 +0900 (JST)
Message-ID: <545904F46F6C4026A234512CEAED30AE@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <D25878F935704D9281E62E0393CAD951@rainbow> <20100729125725.GA3571@csn.ul.ie>
Subject: Re: compaction: why depends on HUGETLB_PAGE
Date: Fri, 30 Jul 2010 11:56:25 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-15";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
>> My question is: why does it depend on CONFIG_HUGETLB_PAGE?
> 
> Because as the Kconfig says "Allows the compaction of memory for the
> allocation of huge pages.". Depending on compaction to satisfy other
> high-order allocation types is not likely to be a winning strategy.

Please could you elaborate a little more why depending on
compaction to satisfy other high-order allocation is not good.

>> Is it wrong to use it on ARM by disabling CONFIG_HUGETLB_PAGE?
>>
> 
> It depends on why you need compaction. If it's for some device that
> requires high-order allocations (particularly if they are atomic), then
> it's not likely to work very well in the long term.

Would you please elaborate on this as well.

Many thanks for the reply
Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
