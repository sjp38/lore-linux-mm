Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3BF426B00C2
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 07:41:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 27DED3EE0BD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:41:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ECE845DEB2
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:41:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E997B45DE9E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:41:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DAD22E08002
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:41:32 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93FB61DB803B
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:41:32 +0900 (JST)
Message-ID: <4FE307E2.3010803@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 20:39:14 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/25] memcg: Always free struct memcg through schedule_work()
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-6-git-send-email-glommer@parallels.com> <4FDF1A0D.6080204@jp.fujitsu.com> <4FDF1AAE.4080209@parallels.com> <alpine.LFD.2.02.1206201031150.2989@tux.localdomain> <4FE18C6B.1020503@parallels.com>
In-Reply-To: <4FE18C6B.1020503@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/06/20 17:40), Glauber Costa wrote:
> On 06/20/2012 11:32 AM, Pekka Enberg wrote:
>>> >Maybe Pekka can merge the current -mm with his tree?
>> I first want to have a stable base from Christoph's "common slab" series
>> before I am comfortable with going forward with the memcg parts.
>>
>> Feel free to push forward any preparational patches to the slab
>> allocators, though.
>>
>> Pekka
>
> Kame and others:
>
> If you are already comfortable with the general shape of the series, it would do me good to do the same with the memcg preparation patches, so we have less code to review and merge in the next window.
>
> They are:
>
> memcg: Make it possible to use the stock for more than one page.
> memcg: Reclaim when more than one page needed.
> memcg: change defines to an enum
>
> Do you see any value in merging them now ?
>

I'll be okay with the 3 patches for memcg.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
