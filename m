Date: Fri, 23 May 2008 13:30:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
In-Reply-To: <4836411B.2030601@linux.vnet.ibm.com>
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com> <4836411B.2030601@linux.vnet.ibm.com>
Message-Id: <20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

> One option is to limit the virtual address space usage of the cgroup to ensure
> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
> good swap controller, it should provide good control over the cgroup's memory usage.

unfortunately, it doesn't works in real world.
IMHO you said as old good age.

because, Some JavaVM consume crazy large virtual address space.
it often consume >10x than phycal memory consumption.

yes, that behaviour is crazy. but it is used widely.
thus, We shouldn't assume virtual address space limitation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
