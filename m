Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4E0BB6B00E7
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:12:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D62EC3EE0C3
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:12:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCF5645DEB3
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:12:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F46145DEB7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:12:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CFE01DB8043
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:12:36 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1360F1DB8044
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:12:36 +0900 (JST)
Message-ID: <4FB05B8F.8020408@jp.fujitsu.com>
Date: Mon, 14 May 2012 10:10:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] add res_counter_uncharge_until()
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACE01A.4040405@jp.fujitsu.com> <20120511141945.c487e94c.akpm@linux-foundation.org>
In-Reply-To: <20120511141945.c487e94c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/12 6:19), Andrew Morton wrote:

> On Fri, 11 May 2012 18:47:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> From: Frederic Weisbecker <fweisbec@gmail.com>
>>
>> At killing res_counter which is a child of other counter,
>> we need to do
>> 	res_counter_uncharge(child, xxx)
>> 	res_counter_charge(parent, xxx)
>>
>> This is not atomic and wasting cpu. This patch adds
>> res_counter_uncharge_until(). This function's uncharge propagates
>> to ancestors until specified res_counter.
>>
>> 	res_counter_uncharge_until(child, parent, xxx)
>>
>> Now, ops is atomic and efficient.
>>
>> Changelog since v2
>>  - removed unnecessary lines.
>>  - Fixed 'From' , this patch comes from his series. Please signed-off-by if good.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Frederic's Signed-off-by: is unavaliable?
> 

I didn't add his Signed-off because I modified his orignal patch a little...
I dropped res_counter_charge_until() because it's not used in this series,
I have no justification for adding it.
The idea of res_counter_uncharge_until() is from his patch.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
