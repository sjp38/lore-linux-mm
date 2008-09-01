Date: Mon, 1 Sep 2008 18:53:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
	<20080901165827.e21f9104.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Sep 2008 17:53:02 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 1 Sep 2008 16:58:27 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 1 Sep 2008 16:15:01 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > Hi, Kamezawa-san.
> > > 
> > > I'm testing these patches on mmotm-2008-08-29-01-08
> > > (with some trivial fixes I've reported and some debug codes),
> This problem happens on the kernel without debug codes I added.
> 
> > > but swap_in_bytes sometimes becomes very huge(it seems that
> > > over uncharge is happening..) and I can see OOM
> > > if I've set memswap_limit.
> > > 
> > > I'm digging this now, but have you also ever seen it?
> > > 
> > I didn't see that.
> I see, thanks.
> 
> > But, as you say, maybe over-uncharge. Hmm..
> > What kind of test ? Just use swap ? and did you use shmem or tmpfs ?
> > 
> I don't do anything special, and this can happen without shmem/tmpfs
> (can happen with shmem/tmpfs, too).
> 
> For example:
> 
> - make swap out/in activity for a while(I used page01 of ltp).
> - stop the test.
> 
> [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> 4096
> 
> - swapoff
> 
> [root@localhost ~]# swapoff -a
> [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> 18446744073709395968
> 
> 
Hmm ? can happen without swapoff ?
It seems "accounted" flag is on by mistake.


Maybe I missed some...but thank you. I'll try.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
