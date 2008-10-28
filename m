Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9S0A1iB022024
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 09:10:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF0F62AC025
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:10:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B157312C0AF
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:10:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BCD41DB803B
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:10:00 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21D971DB8040
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:10:00 +0900 (JST)
Date: Tue, 28 Oct 2008 09:09:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 10/11] memcg: swap cgroup
Message-Id: <20081028090931.bd52d14d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081027160216.29196b96.nishimura@mxp.nes.nec.co.jp>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181349.63096aeb.kamezawa.hiroyu@jp.fujitsu.com>
	<20081027160216.29196b96.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Oct 2008 16:02:16 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +	memset(array, 0, array_size);
> > +	ctrl = &swap_cgroup_ctrl[type];
> > +	mutex_lock(&swap_cgroup_mutex);
> > +	ctrl->length = length;
> > +	ctrl->map = array;
> > +	if (swap_cgroup_prepare(type)) {
> > +		/* memory shortage */
> > +		ctrl->map = NULL;
> > +		ctrl->length = 0;
> > +		vfree(array);
> > +		mutex_unlock(&swap_cgroup_mutex);
> > +		goto nomem;
> > +	}
> > +	mutex_unlock(&swap_cgroup_mutex);
> > +
> > +	printk(KERN_INFO
> > +		"swap_cgroup: uses %ldbytes vmalloc and %ld bytes buffres\n",
> just a minor nitpick, s/ldbytes/ld bytes.
> 
yes. thank you for review.

-Kame

> 
> Thanks,
> Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
