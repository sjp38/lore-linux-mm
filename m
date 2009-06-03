Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 955836B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:25:25 -0400 (EDT)
Date: Wed, 3 Jun 2009 14:01:02 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm 2/2] memcg: allow mem.limit bigger than
 memsw.limit iff unlimited
Message-Id: <20090603140102.72b04b6f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090603125228.368ecaf7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603115027.80f9169b.nishimura@mxp.nes.nec.co.jp>
	<20090603125228.368ecaf7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009 12:52:28 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 3 Jun 2009 11:50:27 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Now users cannot set mem.limit bigger than memsw.limit.
> > This patch allows mem.limit bigger than memsw.limit iff mem.limit==unlimited.
> > 
> > By this, users can set memsw.limit without setting mem.limit.
> > I think it's usefull if users want to limit memsw only.
> > They must set mem.limit first and memsw.limit to the same value now for this purpose.
> > They can save the first step by this patch.
> > 
> 
> I don't like this. No benefits to users.
> The user should know when they set memsw.limit they have to set memory.limit.
> This just complicates things.
> 
Hmm, I think there is a user who cares only limitting logical memory(mem+swap),
not physical memory, and wants kswapd to reclaim physical memory when congested. 
At least, I'm a such user.

Do you disagree even if I add a file like "memory.allow_limit_memsw_only" ?


Thanks,
Daisuke Nishimura.

> If you want to do this, add an interface as
>   memory.all.limit_in_bytes (or some better name)
> and allow to set memory.limit and memory.memsw.limit _at once_.
> 
> But I'm not sure it's worth to try. Saving user's few steps by the kenerl patch ?
> 
> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
