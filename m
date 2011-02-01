Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4977F8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:25:03 -0500 (EST)
Date: Mon, 31 Jan 2011 16:24:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge
 pages to near-limit group
Message-Id: <20110131162448.e791f0ae.akpm@linux-foundation.org>
In-Reply-To: <20110201000455.GB19534@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
	<20110201000455.GB19534@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Feb 2011 01:04:55 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Maybe it would be better to use res_counter_margin(cnt) >= wanted
> throughout the code.

yup.

> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -182,6 +182,14 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
>  	return ret;
>  }
>  
> +/**
> + * res_counter_check_margin - check if the counter allows charging
> + * @cnt: the resource counter to check
> + * @bytes: the number of bytes to check the remaining space against
> + *
> + * Returns a boolean value on whether the counter can be charged
> + * @bytes or whether this would exceed the limit.
> + */
>  static inline bool res_counter_check_margin(struct res_counter *cnt,
>  					    unsigned long bytes)
>  {

mem_cgroup_check_margin() needs some lipstick too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
