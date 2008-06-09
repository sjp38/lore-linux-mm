Date: Mon, 9 Jun 2008 09:54:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg fix handle swap cache (was Re: memcg: bad page at
 page migration)
Message-Id: <20080609095410.d3cd5c22.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080607152309.a003b181.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
	<20080607152309.a003b181.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 7 Jun 2008 15:23:09 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Nishimura-san, thank you for your precise report!.
> 
> I think this is a fix. could you try ?
> 
Thank you for tracking it down!

I'll test and report it back later.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
