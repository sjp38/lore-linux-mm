Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i97NWnUI028393 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 08:32:49 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i97NWnND021855 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 08:32:49 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A21EA7CF2
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 08:32:49 +0900 (JST)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AE19A7CF1
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 08:32:48 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I58005QVMQM61@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  8 Oct 2004 08:32:47 +0900 (JST)
Date: Fri, 08 Oct 2004 08:38:24 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
In-reply-to: <1248570000.1097159887@[10.10.2.4]>
Message-id: <4165D370.1090208@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
 <4164E20D.5020400@jp.fujitsu.com> <1248570000.1097159887@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
> The normal way to fix the above is just to have a bitmap array to test - 
> in your case a 1GB granularity would be sufficicent. That takes < 1 word
> to implement for the example above ;-)
> 
> M.
> 

Although I don't like a page fault, I now understand it doesn't often happen.
I'd like to use current implementation.

Thanks

Kame <kamezawa.hiroyu@jp.fujitsu.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
