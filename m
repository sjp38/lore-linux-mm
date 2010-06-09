Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFE66B01D3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 22:13:13 -0400 (EDT)
Date: Wed, 9 Jun 2010 11:05:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages
Message-Id: <20100609110535.8005ef04.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100609095448.1f020a22.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100608163129.9297f3aa.nishimura@mxp.nes.nec.co.jp>
	<20100609095448.1f020a22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010 09:54:48 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 8 Jun 2010 16:31:29 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 8 Jun 2010 12:19:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
(snip)
> > >  1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
> > >     on large smp will not scale well.
> > I'm sorry if I'm asking a stupid question, the number of css_get/put
> > would be:
> > 
> > 	before:
> > 		get:1 in charge
> > 		put:1 in uncharge
> > 	after:
> > 		get:1, put:1 in charge
> > 		no get/put in uncharge
> > 
> > right ?
> 
> No.
> 
> 	before: get 1 in charge.
> 		put 1 at charge
> 
> 	after:
> 		no get at charge in fast path (cunsume_stcok hits.)
> 		get 1 at accssing res_counter and reclaim, put 1 after it.
> 		no get/put in uncharge.
> 
> > Then, isn't there any change as a whole ?
> > 
> We get much benefit when consume_stock() works. 
> 
Ah, I missed comsume_stock(). The number of get/put would be decreased very much.
Thank you for your explanation.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
