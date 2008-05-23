Date: Fri, 23 May 2008 15:00:42 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
In-Reply-To: <4836563B.4060603@anu.edu.au>
References: <48364D38.7000304@linux.vnet.ibm.com> <4836563B.4060603@anu.edu.au>
Message-Id: <20080523145947.84F4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David.Singleton@anu.edu.au
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

> > Have you seen any real world example of this? 
> 
> At the unsophisticated end, there are lots of (Fortran) HPC applications
> with very large static array declarations but only "use" a small fraction
> of that.  Those users know they only need a small fraction and are happy
> to volunteer small physical memory limits that we (admins/queuing
> systems) can apply.
> 
> At the sophisticated end, the use of numerous large memory maps in
> parallel HPC applications to gain visibility into other processes is
> growing.  We have processes with VSZ > 400GB just because they have
> 4GB maps into 127 other processes.  Their physical page use is of
> the order 2GB.

Ah, agreed.
Fujitsu HPC user said similar things ago.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
