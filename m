From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <3950798.1217234354197.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Jul 2008 17:39:14 +0900 (JST)
Subject: Re: Re: [PATCH 1/2][-mm][resend] res_counter limit change support ebusy
In-Reply-To: <20080722014043.92272350.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080722014043.92272350.akpm@linux-foundation.org>
 <20080714171154.e1cc9943.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Mon, 14 Jul 2008 17:11:54 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fuji
tsu.com> wrote:
>
>> +static inline int res_counter_set_limit(struct res_counter *cnt,
>> +	unsigned long long limit)
>> +{
>> +	unsigned long flags;
>> +	int ret = -EBUSY;
>> +
>> +	spin_lock_irqsave(&cnt->lock, flags);
>> +	if (cnt->usage < limit) {
>> +		cnt->limit = limit;
>> +		ret = 0;
>> +	}
>> +	spin_unlock_irqrestore(&cnt->lock, flags);
>> +	return ret;
>> +}
>
>Need I say it?  This function is waaaaaay too large to be inlined.

Will rework and make this uninlined. (in this week)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
