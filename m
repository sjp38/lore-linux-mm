Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R0MhwH032573 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:22:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R0MhmZ023829 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:22:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s0.gw.fujitsu.co.jp (8.12.10)
	id i7R0MgKw024180 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:22:42 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3200AH7X1SDF@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 09:22:41 +0900 (JST)
Date: Fri, 27 Aug 2004 09:27:53 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <20040826171840.4a61e80d.akpm@osdl.org>
Message-id: <412E8009.3080508@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
 <20040826171840.4a61e80d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


Okay, I'll do more test and if I find atomic ops are slow,
I'll add __XXXPagePrivate() macros.

ps. I usually test codes on Xeon 1.8G x 2 server.

-- Kame

Andrew Morton wrote:
> Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>>In the previous version, I used SetPagePrivate()/ClearPagePrivate()/PagePrivate().
>>But these are "atomic" operation and looks very slow.
>>This is why I doesn't used these macros in this version.
>>
>>My previous version, which used set_bit/test_bit/clear_bit, shows very bad performance
>>on my test, and I replaced it.
> 
> 
> That's surprising.  But if you do intend to use non-atomic bitops then
> please add __SetPagePrivate() and __ClearPagePrivate()

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
