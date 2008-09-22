From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <19184326.1222095015978.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 22 Sep 2008 23:50:15 +0900 (JST)
Subject: Re: Re: [PATCH 4/13] memcg: force_empty moving account
In-Reply-To: <1222093420.16700.2.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222093420.16700.2.camel@lappy.programming.kicks-ass.net>
 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922200025.49ea6d70.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> +			spin_lock_irqsave(&mz->lru_lock, flags);
>> +		} else {
>> +			unlock_page(page);
>> +			put_page(page);
>> +		}
>> +		if (atomic_read(&mem->css.cgroup->count) > 0)
>> +			break;
>>  	}
>>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>
>do _NOT_ use yield() ever! unless you know what you're doing, and
>probably not even then.
>
>NAK!
Hmm, sorry. cond_resched() is ok ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
