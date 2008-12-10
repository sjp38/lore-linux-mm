Date: Wed, 10 Dec 2008 22:47:58 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-Id: <20081210224758.46abbd59.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081210132559.GF25467@balbir.in.ibm.com>
References: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	<29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	<20081210132559.GF25467@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 18:55:59 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-10 20:29:41]:
> 
> > Paul Menage said:
> > > The reason for needing this patch is because of the non-atomic locking
> > > in cgroup_rmdir() that was introduced due to the circular locking
> > > dependency between the hotplug lock and the cgroup_mutex.
> > >
> > > But rather than adding a whole bunch more complexity, this looks like
> > > another case that could be solved by the hierarchy_mutex patches that
> > > I posted a while ago.
> > >
> 
> Paul, I can't find those patches in -mm. I will try and dig them out
> from my mbox. I agree, we need a hierarchy_mutex, cgroup_mutex is
> becoming the next BKL.
> 
Hmm.. but doesn't per-hierarchy-mutex solve the problem if memory and cpuset
mounted on the same hierarchy ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
