Date: Wed, 11 Jun 2008 13:08:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611130816.6dd36a31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080611034514.D482F5A11@siro.lan>
References: <20080611110216.504faf15.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611034514.D482F5A11@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 12:45:14 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > > having said that, if you decide to put too large tasks into
> > > a cgroup with too small limit, i don't think that there are
> > > many choices besides OOM-kill and allowing "exceed".
> > > 
> > IMHO, allowing exceed is harmfull without changing the definition of "limit".
> > "limit" is hard-limit, now, not soft-limit. Changing the defintion just for
> > this is not acceptable for me. 
> 
> even with the current code, the "exceed" condition can be created
> by simply lowering the limit.
> (well, i know that some of your patches floating around change it.)
> 
Yes, I write it now ;) Handling exceed contains some troubles

  - when resizing limit, to what extent exceed is allowed ?
  - Once exceed, no new page allocation can success and
    _some random process_ will die because of OOM.


> > Maybe "move" under limit itself is crazy ops....Hmm...
> > 
> > Should we allow task move when the destination cgroup is unlimited ?
> > Isn't it useful ?
> 
> i think it makes some sense.
> 
> > > actually, i think that #3 and #5 are somewhat similar.
> > > a big difference is that, while #5 shrinks the cgroup immediately,
> > > #3 does it later.  in case we need to do OOM-kill, i prefer to do it
> > > sooner than later.
> > > 
> > #3 will not cause OOM-killer, I hope...A user can notice memory shortage.
> 
> we are talking about the case where a cgroup's working set is getting
> hopelessly larger than its limit.  i don't see why #3 will not
> cause OOM-kill.  can you explain?
> 
just because #3 doesn't move resource, just drop. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
