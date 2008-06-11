Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: Your message of "Wed, 11 Jun 2008 12:25:00 +0900"
	<20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080611034446.4C5535A23@siro.lan>
Date: Wed, 11 Jun 2008 12:44:46 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> I'm now considering following logic. How do you think ?
> 
> Assume: move TASK from group:CURR to group:DEST.
> 
> == move_task(TASK, CURR, DEST)
> 
> if (DEST's limit is unlimited)
> 	moving TASK
> 	return success.
> 
> usage = check_usage_of_task(TASK).
> 
> /* try to reserve enough room in destionation */
> if (try_to_reserve_enough_room(DEST, usage)) {
> 	move TASK to DEST and move pages AMAP.
> 	/* usage_of_task(TASK) can be changed while we do this.
> 	   Then, we move AMAP. */
> 	return success;
> }
> return failure.
> ==

AMAP means that you might leave some random charges in CURR?

i think that you can redirect new charges in TASK to DEST
so that usage_of_task(TASK) will not grow.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
