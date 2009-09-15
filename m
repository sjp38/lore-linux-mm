Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E6246B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 20:11:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8F0Bimp012582
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Sep 2009 09:11:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B82545DE54
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:11:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA5045DE51
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:11:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41B5D1DB803E
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:11:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 012DA1DB8038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:11:44 +0900 (JST)
Date: Tue, 15 Sep 2009 09:09:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4][mmotm] memcg: coalescing charge
Message-Id: <20090915090926.3ec13958.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090912135825.7f78a247.d-nishimura@mtf.biglobe.ne.jp>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090909174533.3b607bd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090912135825.7f78a247.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 12 Sep 2009 13:58:25 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> > @@ -1320,6 +1423,9 @@ static int __mem_cgroup_try_charge(struc
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto nomem;
> >  
> > +		/* we don't make stocks if failed */
> > +		csize = PAGE_SIZE;
> > +
> >  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> >  						gfp_mask, flags);
> >  		if (ret)
> It might be a nitpick though, isn't it better to move csize modification
> before checking __GFP_WAIT ?
> It might look like:
> 
> 	/* we don't make stocks if failed */
> 	if (csize > PAGE_SIZE) {
> 		csize = PAGE_SIZE;
> 		continue;
> 	}
> 
> 	if (!(gfp_mask & __GFP_WAIT))
> 		goto nomem;
> 
Hmm ok. thank you.
Because it's in merge-window, I don't push this series but will post
new version just for showing updates.

Thanks,
-Kame


> Thanks,
> Daisuke Nishimura.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
