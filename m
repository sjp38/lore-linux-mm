Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9323F6001DA
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 20:16:14 -0500 (EST)
Date: Fri, 5 Feb 2010 10:16:02 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-ID: <20100205011602.GA8416@linux-sh.org>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp> <20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp> <20100203193127.fe5efa17.akpm@linux-foundation.org> <20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp> <20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com> <20100204071840.GC5574@linux-sh.org> <20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com> <20100205093806.5699d406.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100205093806.5699d406.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 05, 2010 at 09:38:06AM +0900, Daisuke Nishimura wrote:
> On Thu, 4 Feb 2010 16:44:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 4 Feb 2010 16:18:40 +0900
> > Paul Mundt <lethal@linux-sh.org> wrote:
> > > CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
> > > stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
> > > chance to optimize things away in those cases, too. Embedded systems
> > > especially will often have MMU=y and BLOCK=n, resulting in SWAP being
> > > unset but swap cache encodings still defined.
> > > 
> > > How about just changing the is_swap_pte() definition to depend on SWAP
> > > instead?
> > > 
> > I think the new feature as "move task charge" itself depends on CONFIG_MMU
> > because it walks a process's page table. 
> > 
> > Then, how about this ? (sorry, I can't test this in valid way..)
> > 
> I agree to this direction of making "move charge" depend on CONFIG_MMU,
> although I can't test !CONFIG_MMU case either.
> 
I'll try to give it a test on nommu today and see how it goes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
