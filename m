Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 26CC76B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:16:45 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0MFGgMd018015
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 23 Jan 2010 00:16:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A65145DE4F
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 00:16:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DCECF45DE4E
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 00:16:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C396C1DB803C
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 00:16:41 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 842A21DB8040
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 00:16:41 +0900 (JST)
Message-ID: <ea36dc1ede8240f85a69215be964c61a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <1264168844.2789.4.camel@barrios-desktop>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
    <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
    <1264168844.2789.4.camel@barrios-desktop>
Date: Sat, 23 Jan 2010 00:16:40 +0900 (JST)
Subject: Re: [PATCH v2] oom-kill: add lowmem usage aware oom kill handling
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> On Fri, 2010-01-22 at 15:23 +0900, KAMEZAWA Hiroyuki wrote:
>> updated. thank you for review.

>>  	CONSTRAINT_MEMORY_POLICY,
>>  };
>
> <snip>
>> @@ -475,7 +511,7 @@ void mem_cgroup_out_of_memory(struct mem
>>
>>  	read_lock(&tasklist_lock);
>>  retry:
>> -	p = select_bad_process(&points, mem);
>> +	p = select_bad_process(&points, mem, CONSTRAINT_NONE);
>
> Why do you fix this with only CONSTRAINT_NONE?
> I think we can know CONSTRAINT_LOWMEM with gfp_mask in here.
>
memcg is just for accounting anon/file pages. Then, it's never
cause lowmem oom problem (any memory is ok for memcg).



> Any problem?
>
> Otherwise, Looks good to me. :)
>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
Thank you.

-Kame

> --
> Kind regards,
> Minchan Kim
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
