Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 578046B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:59:09 -0400 (EDT)
Received: by vcbfy7 with SMTP id fy7so1284360vcb.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:59:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120427182018.GI26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A34B2.8080103@jp.fujitsu.com>
	<20120427182018.GI26595@google.com>
Date: Sat, 28 Apr 2012 08:59:08 +0900
Message-ID: <CABEgKgooq6EUFRC2-19QxACpGN5+EHn=OwPzk+tMBLy-pYM9XQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in move_parent
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 28, 2012 at 3:20 AM, Tejun Heo <tj@kernel.org> wrote:
> On Fri, Apr 27, 2012 at 02:54:58PM +0900, KAMEZAWA Hiroyuki wrote:
>> By using res_counter_uncharge_until(), we can avoid
>> unnecessary charging.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/memcontrol.c | =A0 63 ++++++++++++++++++++++++++++++++++++--------=
----------
>> =A01 files changed, 42 insertions(+), 21 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 613bb15..ed53d64 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2420,6 +2420,24 @@ static void __mem_cgroup_cancel_charge(struct mem=
_cgroup *memcg,
>> =A0}
>>
>> =A0/*
>> + * Cancel chages in this cgroup....doesn't propagates to parent cgroup.
>
> =A0 =A0 =A0 =A0 =A0 =A0 ^typo =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ^ unnecessary s

Ya, thanks. I'll fix it.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
