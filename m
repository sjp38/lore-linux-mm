Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DE0096B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:07:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D77bvC012283
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 16:07:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7361645DE65
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:07:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 350E945DE5D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:07:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 050651DB8049
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:07:37 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ECCD1DB803E
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:07:36 +0900 (JST)
Message-ID: <7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: 
     <7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
    <7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com>
Date: Fri, 13 Mar 2009 16:07:35 +0900 (JST)
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki さんは書きました：
> Balbir Singh さんは書きました：
>>
>> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> New Feature: Soft limits for memory resource controller.
>>
>> Changelog v5...v4
>> 1. Several changes to the reclaim logic, please see the patch 4 (reclaim
>> on
>>    contention). I've experimented with several possibilities for reclaim
>>    and chose to come back to this due to the excellent behaviour seen
>> while
>>    testing the patchset.
>> 2. Reduced the overhead of soft limits on resource counters very
>> significantly.
>>    Reaim benchmark now shows almost no drop in performance.
>>
> It seems there are no changes to answer my last comments.
>
> Nack again. I'll update my own version again.
>
Sigh, this is in -mm ? okay...I'll update onto -mm as much as I can.
Very heavy work, maybe.
Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
