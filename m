From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <32834312.1213622802513.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 16 Jun 2008 22:26:42 +0900 (JST)
Subject: Re: Re: [PATCH 1/6] res_counter:  handle limit change
In-Reply-To: <48565CBA.2040309@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48565CBA.2040309@linux.vnet.ibm.com>
 <48562AFF.9050804@linux.vnet.ibm.com> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <400765.1213607050433.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, xemul@openvz.org, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>> Definitely No. I think counters which cannot be shrink should return -EBUSY
>> by shrink_usage() when it cannot do it. 
>
>Wouldn't that be all counters except for the memory controller RSS counter? I
>can't see anyone besides the memory controller supporting shrink_usage().
>
Slab_counter is a candidate. But ok, if everyone doesn't like this,
I'll abandon the whole and rewrite it as v3. 

And condidering your point, my high-low-watermark patch set should be
implemented within memcg and adding high/low to res_counter is too bad.
I'll change my plan. But res_counter is less useful rather than I thought of ;
)
Besides it doesn't support any feedbacks, it just restricts the access to para
meters.

BTW, I believe current res_counter's behavior to return success
at usage > limit case is very bad. I'd like to return -EBUSY.
How do you think ?
(And I also think res_counter_charge returns -ENOMEM is BUG. It should be
 -EBUSY.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
