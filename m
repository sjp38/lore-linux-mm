Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 09C966B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 11:11:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n31FBCjc030989
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Apr 2009 00:11:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C19C745DD76
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 00:11:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A048E45DD75
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 00:11:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B1D91DB8012
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 00:11:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BCAF1DB8017
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 00:11:12 +0900 (JST)
Message-ID: <fe5dec67977261684809e4fb7a63dbc1.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090401144252.GE4210@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090401144252.GE4210@balbir.in.ibm.com>
Date: Thu, 2 Apr 2009 00:11:11 +0900 (JST)
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
>> ==brief test result==
>> On 2CPU/1.6GB bytes machine. create group A and B
>>   A.  soft limit=300M
>>   B.  no soft limit
>>
>>   Run a malloc() program on B and allcoate 1G of memory. The program
>> just
>>   sleeps after allocating memory and no memory refernce after it.
>>   Run make -j 6 and compile the kernel.
>>
>>   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
>>   When vm.swappiness = 10  => 1MB of memory are swapped out from B
>>
>>   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
>>
>
> I did some brief functionality tests and the results are far better
> than the previous versions of the patch. Both my v7 (with some minor
> changes) and this patchset seem to do well functionally. Time to do
> some more exhaustive tests. Any results from your end?
>
Grad to hear that.

Seems good result under several simple tests after fixing
inactive_anon_is_low(). But needed some fixes for corner cases,
add hook to uncharge, hook to cpu hotplug, etc....and making codes
slim, tuning parameters to make more sense. (or adding comments.)

I wonder whether it's convenient to post v2 before new mmotm.
(mmotm includes some fixes around memcg/vmscan.)
I'll continue test (hopefully more complicated cases on big machine.)

Anyway, I often update patch to v5 or more before posting final ones ;)

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
