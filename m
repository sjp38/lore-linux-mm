Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 276AC8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 23:48:00 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C63363EE0AE
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:47:46 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ACB9F45DE6A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:47:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9578045DE68
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:47:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8730AE08003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:47:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FA24E38003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:47:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock contention
In-Reply-To: <1299559453.2337.30.camel@sli10-conroe>
References: <AANLkTikxoONF16WduKaRKpTFKkZbAR==UA1_a+3qzRV2@mail.gmail.com> <1299559453.2337.30.camel@sli10-conroe>
Message-Id: <20110308134633.7EBF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  8 Mar 2011 13:47:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

> > > +#ifdef CONFIG_SMP
> > > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> > 
> > Why do we have to handle SMP and !SMP?
> > We have been not separated in case of pagevec using in swap.c.
> > If you have a special reason, please write it down.
> this is to reduce memory footprint as suggested by akpm.
> 
> Thanks,
> Shaohua

Hi Shaouhua,

I agree with you. But, please please avoid full quote. I don't think
it is so much difficult work. ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
