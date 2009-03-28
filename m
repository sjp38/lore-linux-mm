Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C36EF6B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 12:10:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2SGAcEN011015
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 29 Mar 2009 01:10:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F4C245DD76
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 01:10:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4979245DD72
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 01:10:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 477261DB8018
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 01:10:38 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0053D1DB8012
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 01:10:38 +0900 (JST)
Message-ID: <cb947346323dc0c602b6aad8eec13263.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090328082350.GS24227@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090328082350.GS24227@balbir.in.ibm.com>
Date: Sun, 29 Mar 2009 01:10:37 +0900 (JST)
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
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27
> 13:59:33]:

>>   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
>>   When vm.swappiness = 10  => 1MB of memory are swapped out from B
>>
>>   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
>>
>
> How did you calculate the swap usage of group B?
>
 memsory.memsw.usage_in_bytes - memory.usage_in_bytes.

>> I'll try much more complexed ones in the weekend.
>
> You might want to try experiments where the group with the higher soft
> limit starts much later than the group with lower soft limit and both
> have a high demand for memory. Also try corner cases such as soft
> limits being 0, or groups where soft limits are equal, etc.
>
thx, good input. maybe I need some hook in "set soft limit" path.

> We have a long weekend, so I've been unable to test/review your
> patches. I'll do so soon if possible.
>
thank you.
-Kame

> --
> 	Balbir
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
