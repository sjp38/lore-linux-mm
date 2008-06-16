From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <11930674.1213604250738.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 16 Jun 2008 17:17:30 +0900 (JST)
Subject: Re: Re: [PATCH 1/6] res_counter:  handle limit change
In-Reply-To: <48561B68.6060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48561B68.6060503@openvz.org>
 <48560A7C.9050501@openvz.org> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <33011576.1213601977563.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>> I think when I did all in memcg, someone will comment that "why do that
>> all in memcg ? please implement generic one to avoid code duplication"
>
>Hm... But we're choosing between
>
>sys_write->xxx_cgroup_write->res_counter_set_limit->xxx_cgroup_call
>
>and
>
>sys_write->xxx_cgroup_write->res_counter_set_limit
>                           ->xxx_cgroup_call
>
>With the sizeof(void *)-bytes difference in res_counter, nNo?
>
I can't catch what you mean. What is res_counter_set_limit here ?
(my patche's ?) and what is sizeof(void *)-bytes ?

Is it so strange to add following algorithm in res_counter?
==
set_limit -> fail -> shrink -> set limit -> fail ->shrink
-> success -> return 0
==
I think this is enough generic.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
