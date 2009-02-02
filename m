Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6365F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 09:12:44 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n12EAsuX011547
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 01:10:54 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n12ECsNd1179740
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 01:12:56 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n12ECauq002965
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 01:12:36 +1100
Date: Mon, 2 Feb 2009 19:42:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090202141233.GD918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-02 21:59:34]:

> Hi
> 
> > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> > +{
> > +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> > +		memcg->css.cgroup->dentry->d_name.name);
> > +	printk(KERN_WARNING "Memory cgroup RSS : usage %llu, limit %llu"
> > +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> > +	printk(KERN_WARNING "Memory cgroup swap: usage %llu, limit %llu "
> > +		"failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> 
> s/res/memsw/ ?
> 
> and, I don't like the name of "Memory cgroup RSS" and "Memory cgroup swap".
> it seems misleading. memcg->res doesn't only count count rss, but also cache.
> memcg->memsw doesn't only count swap, but also memory.
> 
> otherthing, I think it is good patch for me :)
>

Good point, I fixed the res/memsw problem and sent out a patch. About
the RSS thing, not sure what to call it, just calling it memory can be
confusing, may be I should call it

Memory and Memory+swap

Thanks for the review 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
