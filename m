Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id DDFA46B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:04:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 02DDB3EE0C0
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:04:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DEF9E45DEAD
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:04:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B255345DEB3
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:04:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A01461DB8046
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:04:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51F841DB8040
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:04:35 +0900 (JST)
Message-ID: <4FB19D14.7080208@jp.fujitsu.com>
Date: Tue, 15 May 2012 09:02:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 6/6] remove __must_check for res_counter_charge_nofail()
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACE184.6020307@jp.fujitsu.com> <20120514200925.GH2366@google.com>
In-Reply-To: <20120514200925.GH2366@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/15 5:09), Tejun Heo wrote:

> On Fri, May 11, 2012 at 06:53:08PM +0900, KAMEZAWA Hiroyuki wrote:
>> I picked this up from Costa's slub memcg series. For fixing added warning
>> by patch 4.
>> ==
>> From: Glauber Costa <glommer@parallels.com>
>> Subject: [PATCH 6/6] remove __must_check for res_counter_charge_nofail()
>>
>> Since we will succeed with the allocation no matter what, there
>> isn't the need to use __must_check with it. It can very well
>> be optional.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> For 3-6,
> 
>  Reviewed-by: Tejun Heo <tj@kernel.org>
> 
> Thanks a lot for doing this.  This doesn't solve all the failure paths
> tho.  ie. what about -EINTR failures from lock contention?
> pre_destroy() would probably need delay and retry logic with
> WARN_ON_ONCE() on !-EINTR failures.
> 


Yes, I'll do more work. I tend to split series, sorry.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
