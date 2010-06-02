Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE846B01AF
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 21:46:11 -0400 (EDT)
Date: Wed, 2 Jun 2010 10:39:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][1/3] memcg clean up try charge
Message-Id: <20100602103948.baeb3090.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100602094527.776cc1ce.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601231914.6874165e.d-nishimura@mtf.biglobe.ne.jp>
	<20100602094527.776cc1ce.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> >                 case CHARGE_RETRY: /* not in OOM situation but retry */
> > 			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > 			csize = PAGE_SIZE;
> > 			break;
> > 
> > later.
> > 
> Hmmmmmmm. ok.
> 
> 
I'm sorry that, considering more, this will change current behavior, so I think
your original patch would be better about this part.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
