Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D8BDE6B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 04:37:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D8bOgd010275
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 17:37:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 22D7845DD76
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:37:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE45345DD74
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:37:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C470B1DB8015
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:37:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ED291DB801A
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:37:20 +0900 (JST)
Message-ID: <e62d9b2490f4732cf79b422f5b9cd4eb.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090313072649.GM16897@balbir.in.ibm.com>
References: <20090313145032.AF4D.A69D9226@jp.fujitsu.com>
    <20090313070340.GI16897@balbir.in.ibm.com>
    <20090313160632.683D.A69D9226@jp.fujitsu.com>
    <20090313072649.GM16897@balbir.in.ibm.com>
Date: Fri, 13 Mar 2009 17:37:19 +0900 (JST)
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 16:17:25]:

> 1. Kame's scan logic, selects shrink_zone for the mem cgroup, but the
>    pages scanned and reclaimed from depend on priority and watermarks
>    of the zone and *not* at all on the soft limit parameters.
What means "not at all" ? My test result was illusion ?
My routine reclaims memory from memcg which over soft limit....
What modification is necessary ?
(Anyway, I'll remove priority and introduce something more intellegent here.)

> 2. Because soft limit reclaim fails to reclaim anythoing (due to 1),
>    shrink_zone which is called, does reclaiming indepedent of any
>    knowledge of soft limits, which does not work as expected.
>
I agree that we need some hook to loop in of shrink_zone to taking
care of softlimit.

Thanks,
-Kame


>
> --
> 	Balbir
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
