Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: Your message of "Wed, 11 Jun 2008 11:02:16 +0900"
	<20080611110216.504faf15.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611110216.504faf15.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080611034514.D482F5A11@siro.lan>
Date: Wed, 11 Jun 2008 12:45:14 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> > having said that, if you decide to put too large tasks into
> > a cgroup with too small limit, i don't think that there are
> > many choices besides OOM-kill and allowing "exceed".
> > 
> IMHO, allowing exceed is harmfull without changing the definition of "limit".
> "limit" is hard-limit, now, not soft-limit. Changing the defintion just for
> this is not acceptable for me. 

even with the current code, the "exceed" condition can be created
by simply lowering the limit.
(well, i know that some of your patches floating around change it.)

> Maybe "move" under limit itself is crazy ops....Hmm...
> 
> Should we allow task move when the destination cgroup is unlimited ?
> Isn't it useful ?

i think it makes some sense.

> > actually, i think that #3 and #5 are somewhat similar.
> > a big difference is that, while #5 shrinks the cgroup immediately,
> > #3 does it later.  in case we need to do OOM-kill, i prefer to do it
> > sooner than later.
> > 
> #3 will not cause OOM-killer, I hope...A user can notice memory shortage.

we are talking about the case where a cgroup's working set is getting
hopelessly larger than its limit.  i don't see why #3 will not
cause OOM-kill.  can you explain?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
