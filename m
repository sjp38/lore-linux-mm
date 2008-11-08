Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA82kHwJ012253
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 8 Nov 2008 11:46:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE84E45DD7A
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:46:17 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D85045DD78
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:46:17 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE0F1DB8038
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:46:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CCBB1DB8037
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:46:17 +0900 (JST)
Message-ID: <38971.10.75.179.62.1226112376.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <31630.10.75.179.62.1226111079.squirrel@webmail-b.css.fujitsu.com>
References: <1226096940.8805.4.camel@badari-desktop>
    <31630.10.75.179.62.1226111079.squirrel@webmail-b.css.fujitsu.com>
Date: Sat, 8 Nov 2008 11:46:16 +0900 (JST)
Subject: Re: 2.6.28-rc3 mem_cgroup panic
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki said:
> Badari Pulavarty said:
>> Hi Balbir,
>>
>> I was running memory remove/add tests in a continuous loop.
>> I get following panic in mem_cgroup migration code.
>>
>> Is this a known issue ?
>>
> No, this is new one. We don't see panic in cpuset based migration..so..
> Maybe related to page_cgroup allocation/free code in memory hotplug
> notifier.
>
> Thank you for report. I'll try this.
>
Hmm...at quick look...

online/offline page_cgroup's calculation for "start" is buggy..

-start = start_pfn & (PAGES_PER_SECTION - 1);
+start = start_pfn & ~(PAGES_PER_SECTION - 1);

I'm sorry I can't write patch today.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
