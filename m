Message-ID: <485F2CA2.8060106@ah.jp.nec.com>
Date: Mon, 23 Jun 2008 13:54:58 +0900
From: Takenori Nagano <t-nagano@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [patch] memory reclaim more  efficiently
References: <485EF481.30409@ah.jp.nec.com> <20080623102854.37BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080623102854.37BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Keiichi KII <kii@linux.bs1.fc.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> > Hi nagano-san,
> >
>> >> In shrink_zone(), system can not return to user mode before it finishes to
>> >> search LRU list. IMHO, it is very wasteful, since the user processes stay
>> >> unnecessarily long time in shrink_zone() loop and application response time
>> >> becomes relatively bad. This patch changes shrink_zone() that it finishes
memory
>> >> reclaim when it reclaims enough memory.
>> >>
>> >> the conditions to end searching:
>> >>
>> >> 1. order of request page is 0
>> >> 2. process is not kswapd.
>> >> 3. satisfy the condition to return try_to_free_pages()
>> >>    # nr_reclaim > SWAP_CLUSTER_MAX

Hi Kosaki-san,

> > I have 3 question.
> >
> > 1. Do you have any performance number?

I tested some, but I don't collect data.  :-(
I will test again and post results.

> > 2. I think this patch advocate many try_to_free_pages() called is better than
> >    one try_to_free_page waste long time. right?
> >    and, why do you think so?

I think user process is stopped long time on memory reclaim is not good.
It is enough for user process to reclaim memory is needed. We have kswapd memory
reclaim daemon. I think memory reclaim is kswapd's job.

> > 3. if this patch improve perfomance, I guess DEF_PRIORITY is
> >    too small on your machine.
> >    if DEF_PRIORITY is proportional to system memory, do your problem are solved?

Your idea is so nice.  :-)
IMHO, it is not perfect if reclaimable memory is not on front.

Thanks,
  Takenori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
