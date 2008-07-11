Date: Fri, 11 Jul 2008 20:02:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 1/5] swapcgroup (v3): add cgroup files
Message-Id: <20080711200228.6eb145ca.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1215722136.9398.59.camel@nimitz>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<20080704151747.470d62a3.nishimura@mxp.nes.nec.co.jp>
	<1215722136.9398.59.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: nishimura@mxp.nes.nec.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Hi, Dave-san.

On Thu, 10 Jul 2008 13:35:36 -0700, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> On Fri, 2008-07-04 at 15:17 +0900, Daisuke Nishimura wrote:
> > +config CGROUP_SWAP_RES_CTLR
> > +       bool "Swap Resource Controller for Control Groups"
> > +       depends on CGROUP_MEM_RES_CTLR && SWAP
> > +       help
> > +         Provides a swap resource controller that manages and limits swap usage.
> > +         Implemented as a add-on to Memory Resource Controller.
> 
> Could you make this just plain depend on 'CGROUP_MEM_RES_CTLR && SWAP'
> and not make it configurable?  I don't think the resource usage really
> justifies yet another .config knob to tune and break. :)
> 

I don't stick to using kernel config option.

As I said in my ToDo, I'm going to implement another method
(boot option or something) to disable(or enable?) this feature,
so I can make this config not configurable after it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
