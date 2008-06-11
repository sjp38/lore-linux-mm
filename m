Date: Wed, 11 Jun 2008 13:29:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611132909.2eb38039.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611034446.4C5535A23@siro.lan>
	<20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 13:14:37 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 11 Jun 2008 12:44:46 +0900 (JST)
> yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> 
> > > I'm now considering following logic. How do you think ?
> > > 
> > > Assume: move TASK from group:CURR to group:DEST.
> > > 
> > > == move_task(TASK, CURR, DEST)
> > > 
> > > if (DEST's limit is unlimited)
> > > 	moving TASK
> > > 	return success.
> > > 
> > > usage = check_usage_of_task(TASK).
> > > 
> > > /* try to reserve enough room in destionation */
> > > if (try_to_reserve_enough_room(DEST, usage)) {
> > > 	move TASK to DEST and move pages AMAP.
> > > 	/* usage_of_task(TASK) can be changed while we do this.
> > > 	   Then, we move AMAP. */
> > > 	return success;
> > > }
> > > return failure.
> > > ==
> > 
> > AMAP means that you might leave some random charges in CURR?
> > 
> yes. but we can reduce bad case by some way 
>  - reserve more than necessary.
>  or
>  - read_lock mm->sem while move.
> 
I preffer the latter.
Though it's expencive, I think moving a task would not happen
so offen.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
