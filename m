Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7VNlqtx019742 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:47:52 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7VNlpM7007529 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:47:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7VNlofS006397 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:47:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3C00JGC4RPJF@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  1 Sep 2004 08:47:50 +0900 (JST)
Date: Wed, 01 Sep 2004 08:53:04 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [0/3]
In-reply-to: <20040831162408.3718c83e.akpm@osdl.org>
Message-id: <41350F60.40608@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <41345491.1020209@jp.fujitsu.com>
 <1093969590.26660.4806.camel@nighthawk> <4134FF50.8000300@jp.fujitsu.com>
 <20040831162408.3718c83e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>>Because I had to record some information about shape of mem_map, I used PG_xxx bit.
>>1 bit is maybe minimum consumption.
> 
> 
> The point is that we're running out of bits in page.flags.
> 
yes.

> You should be able to reuse an existing bit for this application.  PG_lock would suit.

Hmm... PG_buddyend pages in the top of mem_map can be allocated and used as normal pages
,which can be used for Disk I/O.

If I make them as victims to buddy allocator and don't allow to use them,
I can reuse an existing bit.

I'll consider more.

--Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
