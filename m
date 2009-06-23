Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24D786B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 00:14:56 -0400 (EDT)
Date: Tue, 23 Jun 2009 13:13:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] cgroup: fix permanent wait in rmdir
Message-Id: <20090623131333.be387c84.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090623092223.a44e7b20.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090623092223.a44e7b20.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 09:22:23 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 22 Jun 2009 18:37:07 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2
> > 
> > I think this is a minimum fix (in code size and behavior) and because
> > we can take a BIG LOCK, this kind of check is necessary, anyway.
> > Any comments are welcome.
> 
> I'll split this into 2 patches...and I found I should check page-migration, too.
I'll wait a new version, but can you explain in advance this page-migration case ?

> > +static int mem_cgroup_retry_rmdir(struct cgroup_subsys *ss,
> > +				  struct cgroup *cont)
> > +{
> > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> > +
> > +	if (res_counter_read_u64(&memcg->res, RES_USAGE))
It should be &mem->res.

> > +		return 1;
> > +	return 0;
> > +}
> > +
> > +


Thanks,
Daisuke Nishimura.

> Then, modifing swap account logic is not help, at last.
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
