Date: Fri, 4 Jul 2008 09:47:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [3/7] add shmem page to active list.
Message-Id: <20080704094714.ea41ac9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0807032306350.22975@blonde.site>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	<20080702211057.7a7cf3dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080703091144.93465ba5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080703132730.b64dcd19.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807030750110.22097@blonde.site>
	<20080703164320.1087f758.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807032306350.22975@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008 23:28:21 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 3 Jul 2008, KAMEZAWA Hiroyuki wrote:
> > On Thu, 3 Jul 2008 08:03:17 +0100 (BST)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > > On Thu, 3 Jul 2008, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > BTW, is there a way to see the RSS usage of shmem from /proc or somewhere ?
> > > 
> > > No, it's just been a (very weirdly backed!) filesystem until these
> > > -mm developments.  If you add such stats (for more than temporary
> > > debugging), you'll need to use per_cpu counters for it: more global
> > > locking or atomic ops on those paths would be sure to upset SGI.
> > 
> > like zone stat ?
> 
> Like that, yes.  I had been going to suggest adding another couple
> of stats to that (one for in memory, one for on swap, or heading
> to or from swap); but noticed that everything there is an event,
> with the comment "Counters should only be incremented", so it
> would be an abuse to add shmem page counts there.
> 

Thank you for all your advices. It seems there is no another way rather
than using zone_stat. I'll try it first and see what happens.
(It uses per-cpu counter and update global counter when it goes over threshold.)

BTW, measuring performance of file copy on tmpfs is enough to see overhead ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
