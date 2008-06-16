From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <400765.1213607050433.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 16 Jun 2008 18:04:10 +0900 (JST)
Subject: Re: Re: [PATCH 1/6] res_counter:  handle limit change
In-Reply-To: <48562AFF.9050804@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48562AFF.9050804@linux.vnet.ibm.com>
 <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, xemul@openvz.org, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>KAMEZAWA Hiroyuki wrote:
>> Add a support to shrink_usage_at_limit_change feature to res_counter.
>> memcg will use this to drop pages.
>> 
>> Change log: xxx -> v4 (new file.)
>>  - cut out the limit-change part from hierarchy patch set.
>>  - add "retry_count" arguments to shrink_usage(). This allows that we don't
>>    have to set the default retry loop count.
>>  - res_counter_check_under_val() is added to support subsystem.
>>  - res_counter_init() is res_counter_init_ops(cnt, NULL)
>> 
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> 
>
>Does shrink_usage() really belong to res_counters? Could a task limiter, a
>CPU/IO bandwidth controller use this callback? Resource Counters were designe
d
>to be generic and work across controllers. Isn't the memory controller a bett
er
>place for such ops.
>
Definitely No. I think counters which cannot be shrink should return -EBUSY
by shrink_usage() when it cannot do it. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
