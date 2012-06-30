Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id ACBEE6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 23:48:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AE2173EE0AE
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:48:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 961C545DEAD
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:48:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8008D45DE9E
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:48:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7162C1DB803C
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:48:05 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 211541DB8038
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:48:05 +0900 (JST)
Message-ID: <4FEE7665.6020409@jp.fujitsu.com>
Date: Sat, 30 Jun 2012 12:45:41 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com> <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com> <20120627154827.GA4420@tiehlicka.suse.cz> <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com> <20120627200926.GR15811@google.com> <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com> <20120627202430.GS15811@google.com> <4FEBD7C0.7090906@jp.fujitsu.com> <20120628183145.GE22641@google.com>
In-Reply-To: <20120628183145.GE22641@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

(2012/06/29 3:31), Tejun Heo wrote:
> Hello, KAME.
>
> On Thu, Jun 28, 2012 at 01:04:16PM +0900, Kamezawa Hiroyuki wrote:
>>> I still wish it's folded into CONFIG_MEMCG and conditionalized just on
>>> CONFIG_SWAP tho.
>>>
>>
>> In old days, memsw controller was not very stable. So, we devided the config.
>> And, it makes size of memory for swap-device double (adds 2bytes per swapent.)
>> That is the problem.
>
> I see.  Do you think it's now reasonable to drop the separate config
> option?  Having memcg enabled but swap unaccounted sounds half-broken
> to me.
>

Hmm. Maybe it's ok if we can keep boot option. I'll cook a patch in the next week.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
