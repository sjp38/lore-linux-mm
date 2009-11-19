Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AA0B36B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 18:54:25 -0500 (EST)
Date: Fri, 20 Nov 2009 08:49:34 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 1/5] cgroup: introduce cancel_attach()
Message-Id: <20091120084934.7d82d616.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <6599ad830911191342q3709338apc14950a6de80b128@mail.gmail.com>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	<20091119132828.29aba7b2.nishimura@mxp.nes.nec.co.jp>
	<6599ad830911191342q3709338apc14950a6de80b128@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Nov 2009 13:42:19 -0800, Paul Menage <menage@google.com> wrote:
> On Wed, Nov 18, 2009 at 8:28 PM, Daisuke Nishimura
> <nishimura@mxp.nes.nec.co.jp> wrote:
> > This patch adds cancel_attach() operation to struct cgroup_subsys.
> > cancel_attach() can be used when can_attach() operation prepares something
> > for the subsys, but we should rollback what can_attach() operation has prepared
> > if attach task fails after we've succeeded in can_attach().
> >
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Acked-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> Reviewed-by: Paul Menage <menage@google.com>
> 
Thanks.

> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * Remember at which subsystem we've failed in
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * can_attach() to call cancel_attach() only
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * against subsystems whose attach() have
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * succeeded(see below).
> 
> Maybe: Remember on which subsystem the can_attach() failed, so that we
> only call cancel_attach() against the subsystems whose can_attach()
> succeeded. (See below)
> 
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * This means can_attach() of this subsystem
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * have failed, so we don't need to call
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A * cancel_attach() against rests of subsystems.
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A */
> 
> Maybe: This subsystem was the one that failed the can_attach() check
> earlier, so we don't need to call cancel_attach() against it or any
> remaining subsystems.
> 
Thank you for your fixes.
They are more clear and correct comments. I'll merge them.


Regards,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
