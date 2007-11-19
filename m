Date: Mon, 19 Nov 2007 10:42:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10]
 calculate mapped ratio for memory cgroup
Message-Id: <20071119104246.d38de797.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <473F12D6.8030607@linux.vnet.ibm.com>
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071116191844.319b2754.kamezawa.hiroyu@jp.fujitsu.com>
	<473F12D6.8030607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 17 Nov 2007 21:42:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Define function for calculating mapped_ratio in memory cgroup.
> > 
> 
> Could you explain what the ratio is used for? Is it for reclaim
> later?
> 
Yes, for later.


> > +	/* usage is recorded in bytes */
> > +	total = mem->res.usage >> PAGE_SHIFT;
> > +	rss = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> > +	return (rss * 100) / total;
> 
> Never tried 64 bit division on a 32 bit system. I hope we don't
> have to resort to do_div() sort of functionality.
> 
Hmm, maybe it's better to make these numebrs be just "long".
I'll try to change per-cpu-counter implementation.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
