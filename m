Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7P0J0wH026407 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:19:00 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7P0J0ti030809 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:19:00 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7P0IxXN006741 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:18:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Z009CU7JKCQ@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed, 25 Aug 2004 09:18:57 +0900 (JST)
Date: Wed, 25 Aug 2004 09:24:06 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC/PATCH] free_area[] bitmap	elimination[1/3]
In-reply-to: <1093392120.4030.119.camel@nighthawk>
Message-id: <412BDC26.8020007@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412B3455.1000604@jp.fujitsu.com>
 <1093366752.1009.44.camel@nighthawk> <412BD597.1050001@jp.fujitsu.com>
 <1093392120.4030.119.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>>But "size" is a variable which is used in memmap_init_zone(size, start_pfn, zone)
>>and I think it is better not to change a name of an inherited variable from a caller.
>>(I say size is inherited from memmap_init_zone() in its meaning.)
> 
> 
> Don't use existing bad code as an example :)  I don't see any good
> reason that you can't change it.  Nobody complains when making variable
> names *more* descriptive.
> 
Hmm, I'll consider more descriptive name and what kind of code is easier to read .

--Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
