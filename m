Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 649C18D0002
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:56:40 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so5014738lbj.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 03:56:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB0DF4A.5010506@jp.fujitsu.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
	<4FACE01A.4040405@jp.fujitsu.com>
	<20120511141945.c487e94c.akpm@linux-foundation.org>
	<4FB05B8F.8020408@jp.fujitsu.com>
	<CAFTL4hwGEhyxZO0sXx5gVyK_xjhMQEbHojJbHzQmVKafNyVWtw@mail.gmail.com>
	<4FB0DF4A.5010506@jp.fujitsu.com>
Date: Mon, 14 May 2012 12:56:38 +0200
Message-ID: <CAFTL4hzFiFDTUAAgo=1RBLFhG5Xe8VEUESkpc-RgN7L-haMMbA@mail.gmail.com>
Subject: Re: [PATCH 2/6] add res_counter_uncharge_until()
From: Frederic Weisbecker <fweisbec@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

2012/5/14 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> There may be some special cases with "Original-patch-from:" tags used when
>> one heavily inspire from a patch without taking much of its original code.
>>
>
>
> Is this ok ?

Yep, or even better since I plan to use my company's address now to
sign my patches:

Signed-off-by: Frederic Weisbecker <fweisbec@redhat.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
