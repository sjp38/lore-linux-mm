Date: Mon, 23 Jun 2008 10:49:10 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] memory reclaim more  efficiently
In-Reply-To: <485EF481.30409@ah.jp.nec.com>
References: <485EF481.30409@ah.jp.nec.com>
Message-Id: <20080623102854.37BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takenori Nagano <t-nagano@ah.jp.nec.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Keiichi KII <kii@linux.bs1.fc.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi nagano-san,

> In shrink_zone(), system can not return to user mode before it finishes to
> search LRU list. IMHO, it is very wasteful, since the user processes stay
> unnecessarily long time in shrink_zone() loop and application response time
> becomes relatively bad. This patch changes shrink_zone() that it finishes memory
> reclaim when it reclaims enough memory.
> 
> the conditions to end searching:
> 
> 1. order of request page is 0
> 2. process is not kswapd.
> 3. satisfy the condition to return try_to_free_pages()
>    # nr_reclaim > SWAP_CLUSTER_MAX

I have 3 question.

1. Do you have any performance number?
2. I think this patch advocate many try_to_free_pages() called is better than
   one try_to_free_page waste long time. right?
   and, why do you think so?
3. if this patch improve perfomance, I guess DEF_PRIORITY is
   too small on your machine.
   if DEF_PRIORITY is proportional to system memory, do your problem are solved?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
