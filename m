Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E21B6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 03:13:04 -0500 (EST)
Date: Fri, 23 Jan 2009 17:04:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/7] memcg : use CSS ID in memcg
Message-Id: <20090123170448.5eac1026.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090123162232.5a81e0d3.nishimura@mxp.nes.nec.co.jp>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090122183557.3b058e98.kamezawa.hiroyu@jp.fujitsu.com>
	<20090123162232.5a81e0d3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > +static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
> > +{
> > +	s64 ret;
> > +
> It would be better to initialize it to 0.
> 
> > +	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
> > +	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
> > +	return ret;
> > +}
> > +
Ah, ret is initialized by mem_cgroup_read_stat...

please ignore the above comment.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
