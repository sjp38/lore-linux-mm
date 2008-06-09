Date: Mon, 9 Jun 2008 13:35:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg fix handle swap cache (was Re: memcg: bad page at
 page migration)
Message-Id: <20080609133521.1b1a3d81.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080609124825.cc0b70c2.nishimura@mxp.nes.nec.co.jp>
References: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
	<20080607152309.a003b181.kamezawa.hiroyu@jp.fujitsu.com>
	<20080609124825.cc0b70c2.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jun 2008 12:48:25 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Sat, 7 Jun 2008 15:23:09 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Nishimura-san, thank you for your precise report!.
> > 
> > I think this is a fix. could you try ?
> > 
> 
> In my test environment, infinite loop of page migration runs
> for several hours without errors.
> Thank you for fixing this problem!
> 
> 
> Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
Thank you!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
