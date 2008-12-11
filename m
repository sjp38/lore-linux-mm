Return-Path: <linux-kernel-owner+w=401wt.eu-S1756051AbYLKDYV@vger.kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: show real limit under hierarchy
In-Reply-To: <20081211121135.e00f6a2d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081211121135.e00f6a2d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20081211122237.4FF7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Dec 2008 12:24:07 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> I wonder other people who debugs memcg's hierarchy may use similar patches.
> this is my one.
> comments ?
> ==
> From:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Show "real" limit of memcg.
> This helps my debugging and maybe useful for users.
> 
> While testing hierarchy like this
> 
> 	mount -t cgroup none /cgroup -t memory
> 	mkdir /cgroup/A
> 	set use_hierarchy==1 to "A"
> 	mkdir /cgroup/A/01
> 	mkdir /cgroup/A/01/02
> 	mkdir /cgroup/A/01/03
> 	mkdir /cgroup/A/01/03/04
> 	mkdir /cgroup/A/08
> 	mkdir /cgroup/A/08/01
> 	....
> and set each own limit to them, "real" limit of each memcg is unclear.
> This patch shows real limit by checking all ancestors in memory.stat.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Great!

I hoped to use this patch at hierarchy inactive_ratio debugging ;)
