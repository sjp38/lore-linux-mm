Message-ID: <49056AF3.1000901@cn.fujitsu.com>
Date: Mon, 27 Oct 2008 15:17:07 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 9/11] memcg : mem+swap controlelr kconfig
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>	<20081023181220.80dc24c5.kamezawa.hiroyu@jp.fujitsu.com> <20081027153911.c28285ad.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081027153911.c28285ad.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> BTW, is there any reason to call cgroup_init_subsys() even when the subsys
> is disabled by boot option?
> 

Yes, because cgroup_init_subsys() is called by cgroup_init() and cgroup_init_early().
When cgroup_init_earsy() gets called, the boot param hasn't been parsed, so we don't
know which subsystems are disabled at that time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
