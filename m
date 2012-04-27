Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id A6B476B004D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:51:43 -0400 (EDT)
Received: by vcbfy7 with SMTP id fy7so1280828vcb.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:51:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120427181840.GH26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A343F.7020409@jp.fujitsu.com>
	<20120427181840.GH26595@google.com>
Date: Sat, 28 Apr 2012 08:51:42 +0900
Message-ID: <CABEgKgrqW++YxikPC4tzHA6Yad0YZx7fqfdaYQHXixF+eB6Bjw@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/7 v2] res_counter: add res_counter_uncharge_until()
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 28, 2012 at 3:18 AM, Tejun Heo <tj@kernel.org> wrote:
> On Fri, Apr 27, 2012 at 02:53:03PM +0900, KAMEZAWA Hiroyuki wrote:
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index d508363..f4ec411 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -66,6 +66,8 @@ done:
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> +
>> +
>
> Contamination?

Ah, sorry. I'll fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
