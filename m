Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D91928D0039
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 17:24:43 -0500 (EST)
Date: Mon, 14 Feb 2011 23:24:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
Message-ID: <20110214222421.GZ27110@cmpxchg.org>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
 <20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp>
 <20110209155246.69a7f3a1.kamezawa.hiroyu@jp.fujitsu.com>
 <20110209200728.GQ3347@random.random>
 <alpine.LSU.2.00.1102102243160.2331@sister.anvils>
 <20110211104906.GE3347@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110211104906.GE3347@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Feb 11, 2011 at 11:49:06AM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 10, 2011 at 11:02:50PM -0800, Hugh Dickins wrote:
> > There is a separate little issue here, Andrea.
> > 
> > Although we went to some trouble for bad_page() to take the page out
> > of circulation yet let the system continue, your VM_BUG_ON(!PageBuddy)
> > inside __ClearPageBuddy(page), from two callsites in bad_page(), is
> > turning it into a fatal error when CONFIG_DEBUG_VM.
> 
> I see what you mean. Of course it is only a problem after bad_page
> already triggered.... but then it trigger an BUG_ON instead of only a
> bad_page.
> 
> > You could that only MM developers switch CONFIG_DEBUG_VM=y, and they
> > would like bad_page() to be fatal; maybe, but if so we should do that
> > as an intentional patch, rather than as an unexpected side-effect ;)
> 
> Fedora kernels are built with CONFIG_DEBUG_VM, all my kernels runs
> with CONFIG_DEBUG_VM too, so we want it to be as "production" as
> possible, and we don't want DEBUG_VM to decrease any reliability (only
> to increase it of course).

Are you sure?

$ grep DEBUG_VM /boot/config-*
/boot/config-2.6.35.10-74.fc14.x86_64:# CONFIG_DEBUG_VM is not set
/boot/config-2.6.35.6-45.fc14.x86_64:# CONFIG_DEBUG_VM is not set

Only the one from the kernel-debug package has it set on this F14.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
