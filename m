Return-Path: <linux-kernel-owner+w=401wt.eu-S1757806AbYLLBZf@vger.kernel.org>
Date: Fri, 12 Dec 2008 10:24:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: show real limit under hierarchy
Message-Id: <20081212102413.533057f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <661de9470812110600i6097ca0q7a2d7250f6c493dc@mail.gmail.com>
References: <20081211121135.e00f6a2d.kamezawa.hiroyu@jp.fujitsu.com>
	<20081211122237.4FF7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<661de9470812110600i6097ca0q7a2d7250f6c493dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Dec 2008 19:30:46 +0530
"Balbir Singh" <balbir@linux.vnet.ibm.com> wrote:

> On Thu, Dec 11, 2008 at 8:54 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> I wonder other people who debugs memcg's hierarchy may use similar patches.
> >> this is my one.
> >> comments ?
> >> ==
> >> From:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> Show "real" limit of memcg.
> >> This helps my debugging and maybe useful for users.
> >>
> >> While testing hierarchy like this
> >>
> >>       mount -t cgroup none /cgroup -t memory
> >>       mkdir /cgroup/A
> >>       set use_hierarchy==1 to "A"
> >>       mkdir /cgroup/A/01
> >>       mkdir /cgroup/A/01/02
> >>       mkdir /cgroup/A/01/03
> >>       mkdir /cgroup/A/01/03/04
> >>       mkdir /cgroup/A/08
> >>       mkdir /cgroup/A/08/01
> >>       ....
> >> and set each own limit to them, "real" limit of each memcg is unclear.
> >> This patch shows real limit by checking all ancestors in memory.stat.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Great!
> >
> > I hoped to use this patch at hierarchy inactive_ratio debugging ;)
> 
> I like this very much too
> 
> I would prefer to use
> 
> min_limit = min(tmp, min_limit); and similarly for min_memsw_limit
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
Thanks, I'll upadte this and forward to Andrew.

-Kame


> Balbir
> 
