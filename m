From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <3373261.1213606902401.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 16 Jun 2008 18:01:42 +0900 (JST)
Subject: Re: Re: [PATCH 1/6] res_counter:  handle limit change
In-Reply-To: <48562894.5080307@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48562894.5080307@openvz.org>
 <4856231B.9050704@openvz.org> <48561B68.6060503@openvz.org> <48560A7C.9050501@openvz.org> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <33011576.1213601977563.kamezawa.hiroyu@jp.fujitsu.com> <11930674.1213604250738.kamezawa.hiroyu@jp.fujitsu.com> <11706925.1213605137616.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> Okay, maye all you want is "don't increase the size of res_counter"
>
>Actually no, what I want is not to put indirections level when
>not required.
>
"not required" ? I think you miss the point that this patch implements some
feedback algorithm in res_counter. If res_counter doesn't support it,
Okay, I'll do in memcg. But please see this request from Paul in the prev vers
ion.
 http://marc.info/?l=linux-mm&m=121257010530546&w=2
And what benefits we can get by implementing feedback per subcgroups ?

>But keeping res_counter as small as possible is also my wish. :)
>
>>>> Is it so strange to add following algorithm in res_counter?
>>>> ==
>>>> set_limit -> fail -> shrink -> set limit -> fail ->shrink
>>>> -> success -> return 0
>>>> ==
>>>> I think this is enough generic.
>>> It is, but my point is - we're calling the set_limit (this is a
>>> res_counter_resize_limit from your patch, sorry for the confusion again)
>>> routine right from the cgroup's write callback and thus can call
>>> the desired "ops->shrink_usage" directly, w/o additional level of
>>> indirection.
>>>
>> Hmm, to do that, I'd like to remove strategy function from res_counter.
>
>Oops... I'm looking at 2.6.26-rc5-mm1's res_counter and don't see such.
>I tried to follow the changes in res_counter, but it looks like I've
>already missed something. 
>
>What do you mean by "strategy function from res_counter"?
>
Please ignore. my confusion.
"don't call res_counter_write() at set limit" is ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
