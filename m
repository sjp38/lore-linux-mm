Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 909386B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:08:33 -0400 (EDT)
Received: by lahi5 with SMTP id i5so4998670lah.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 03:08:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB05B8F.8020408@jp.fujitsu.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
	<4FACE01A.4040405@jp.fujitsu.com>
	<20120511141945.c487e94c.akpm@linux-foundation.org>
	<4FB05B8F.8020408@jp.fujitsu.com>
Date: Mon, 14 May 2012 12:08:31 +0200
Message-ID: <CAFTL4hwGEhyxZO0sXx5gVyK_xjhMQEbHojJbHzQmVKafNyVWtw@mail.gmail.com>
Subject: Re: [PATCH 2/6] add res_counter_uncharge_until()
From: Frederic Weisbecker <fweisbec@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

2012/5/14 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> (2012/05/12 6:19), Andrew Morton wrote:
>
>> On Fri, 11 May 2012 18:47:06 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>> From: Frederic Weisbecker <fweisbec@gmail.com>
>>>
>>> At killing res_counter which is a child of other counter,
>>> we need to do
>>> =A0 =A0 =A0res_counter_uncharge(child, xxx)
>>> =A0 =A0 =A0res_counter_charge(parent, xxx)
>>>
>>> This is not atomic and wasting cpu. This patch adds
>>> res_counter_uncharge_until(). This function's uncharge propagates
>>> to ancestors until specified res_counter.
>>>
>>> =A0 =A0 =A0res_counter_uncharge_until(child, parent, xxx)
>>>
>>> Now, ops is atomic and efficient.
>>>
>>> Changelog since v2
>>> =A0- removed unnecessary lines.
>>> =A0- Fixed 'From' , this patch comes from his series. Please signed-off=
-by if good.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Frederic's Signed-off-by: is unavaliable?
>>
>
> I didn't add his Signed-off because I modified his orignal patch a little=
...
> I dropped res_counter_charge_until() because it's not used in this series=
,
> I have no justification for adding it.
> The idea of res_counter_uncharge_until() is from his patch.

The property of Signed-off-by is that as long as you
carry/relay/modify a patch, you add your
own signed-off-by. But you can't remove the signed off by of somebody
in the chain.

Even if you did a change in the patch, you need to preserve the chain.

There may be some special cases with "Original-patch-from:" tags used when
one heavily inspire from a patch without taking much of its original code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
