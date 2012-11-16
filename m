Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A06196B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 00:08:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ACD293EE0B5
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:08:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9517345DEBF
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:08:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 767C645DEBB
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:08:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6927A1DB8041
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:08:50 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A2341DB803F
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:08:50 +0900 (JST)
Message-ID: <50A5CA16.7070603@jp.fujitsu.com>
Date: Fri, 16 Nov 2012 14:07:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: get rid of once-per-second cache shrinking
 for dead memcgs
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-6-git-send-email-glommer@parallels.com> <50A4B8C8.6020202@jp.fujitsu.com> <50A4F289.1090807@parallels.com>
In-Reply-To: <50A4F289.1090807@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

(2012/11/15 22:47), Glauber Costa wrote:
> On 11/15/2012 01:41 PM, Kamezawa Hiroyuki wrote:
>> (2012/11/15 11:54), Glauber Costa wrote:
>>> The idea is to synchronously do it, leaving it up to the shrinking
>>> facilities in vmscan.c and/or others. Not actively retrying shrinking
>>> may leave the caches alive for more time, but it will remove the ugly
>>> wakeups. One would argue that if the caches have free objects but are
>>> not being shrunk, it is because we don't need that memory yet.
>>>
>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>> CC: Michal Hocko <mhocko@suse.cz>
>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>
>> I agree this patch but can we have a way to see the number of unaccounted
>> zombie cache usage for debugging ?
>>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
> Any particular interface in mind ?
> 

Hmm, it's debug interface and having cgroup file may be bad.....
If it can be seen in bytes or some, /proc/vmstat ?

out_of_track_slabs  xxxxxxx. hm ?

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
