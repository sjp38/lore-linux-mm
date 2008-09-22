Subject: Re: Re: [PATCH 4/13] memcg: force_empty moving account
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <19184326.1222095015978.kamezawa.hiroyu@jp.fujitsu.com>
References: <1222093420.16700.2.camel@lappy.programming.kicks-ass.net>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922200025.49ea6d70.kamezawa.hiroyu@jp.fujitsu.com>
	 <19184326.1222095015978.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 16:56:03 +0200
Message-Id: <1222095363.16700.15.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 23:50 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
> >> +			spin_lock_irqsave(&mz->lru_lock, flags);
> >> +		} else {
> >> +			unlock_page(page);
> >> +			put_page(page);
> >> +		}
> >> +		if (atomic_read(&mem->css.cgroup->count) > 0)
> >> +			break;
> >>  	}
> >>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >
> >do _NOT_ use yield() ever! unless you know what you're doing, and
> >probably not even then.
> >
> >NAK!
> Hmm, sorry. cond_resched() is ok ?

depends on what you want to do, please explain what you're trying to do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
