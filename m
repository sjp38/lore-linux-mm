Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9136B01B4
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 03:03:50 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5B5xmXO001622
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:59:48 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B6B7V31626280
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 02:11:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B6B6RJ015086
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 03:11:07 -0300
Date: Fri, 11 Jun 2010 11:41:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-ID: <20100611061102.GF5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
 <20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-09 15:59:40]:

> +		if (consume_stock(mem)) {
> +			/*
> +			 * It seems dagerous to access memcg without css_get().
> +			 * But considering how consume_stok works, it's not
> +			 * necessary. If consume_stock success, some charges
> +			 * from this memcg are cached on this cpu. So, we
> +			 * don't need to call css_get()/css_tryget() before
> +			 * calling consume_stock().
> +			 */
> +			rcu_read_unlock();
> +			goto done;
> +		}
> +		if (!css_tryget(&mem->css)) {

If tryget fails, can one assume that this due to a race and the mem is
about to be freed?


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
