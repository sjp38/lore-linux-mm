Message-Id: <4836B807.2070602@mxp.nes.nec.co.jp>
Date: Fri, 23 May 2008 21:26:47 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
References: <48350F15.9070007@mxp.nes.nec.co.jp>	 <48351120.6000800@mxp.nes.nec.co.jp>	 <20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <4835656D.4020706@mxp.nes.nec.co.jp> <2f11576a0805220532l668ca59emd37afb60f50b703@mail.gmail.com>
In-Reply-To: <2f11576a0805220532l668ca59emd37afb60f50b703@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 2008/05/22 21:32 +0900, KOSAKI Motohiro wrote:
> perhaps, I don't understand your intention exactly.
> Why can't you make wrapper function?
> 
> e.g.
>     vm_swap_full(page_to_memcg(page))
> 
OK.
I'll try it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
