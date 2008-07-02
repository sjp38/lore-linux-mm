Date: Wed, 2 Jul 2008 23:23:15 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][-mm] [0/7] misc memcg patch set
Message-Id: <20080702232315.51080aac.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san.

> - swap_controller (Maybe Nishimura works on.)
>   The world may change after this...cgroup without swap can appears easily.
> 
Yes, and sorry for delaying submitting the next version of it.

I used most of my time in testing -mm itself last month,
but I'm testing the next version now and goint to submit it
in a few days.

I hope to have some discussion on this topic too
at OLS and LinuxFoundationSyposiumJapan ;)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
