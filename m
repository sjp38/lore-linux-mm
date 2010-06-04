Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D56DA6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 20:31:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o540Uwn3021891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Jun 2010 09:30:59 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0F9645DE5D
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:30:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7781745DE4F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:30:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6386D1DB803C
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:30:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 178041DB8038
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:30:58 +0900 (JST)
Date: Fri, 4 Jun 2010 09:26:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg clean up try_charge main loop
Message-Id: <20100604092641.e1e5a7c1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603193809.9d5f6314.d-nishimura@mtf.biglobe.ne.jp>
References: <20100603114837.6e6d4d0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603150619.4bbe61bb.nishimura@mxp.nes.nec.co.jp>
	<20100603152830.8b9e5e27.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603193809.9d5f6314.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010 19:38:09 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> One more comment.
> 
> > +	ret = res_counter_charge(&mem->res, csize, &fail_res);
> > +
> > +	if (likely(!ret)) {
> > +		if (!do_swap_account)
> > +			return CHARGE_OK;
> > +		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
> > +		if (likely(!ret))
> > +			return CHARGE_OK;
> > +
> > +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> This must be mem_cgroup_from_res_counter(fail_res, memsw).
> We will access to an invalid pointer, otherwise.
> 
ouch..ok. (my test wasn't enough..)

I'll rewrite this against the new mmotm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
