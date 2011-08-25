Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 96FF06B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 11:11:54 -0400 (EDT)
Date: Thu, 25 Aug 2011 10:11:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
In-Reply-To: <1314284272.27911.32.camel@twins>
Message-ID: <alpine.DEB.2.00.1108251009120.27407@router.home>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>  <20110818144025.8e122a67.akpm@linux-foundation.org> <1314284272.27911.32.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org

On Thu, 25 Aug 2011, Peter Zijlstra wrote:

> On Thu, 2011-08-18 at 14:40 -0700, Andrew Morton wrote:
> >
> > I think I'll apply it, as the call frequency is low (correct?) and the
> > problem will correct itself as other architectures implement their
> > atomic this_cpu_foo() operations.
>
> Which leads me to wonder, can anything but x86 implement that this_cpu_*
> muck? I doubt any of the risk chips can actually do all this.
> Maybe Itanic, but then that seems to be dying fast.

The cpu needs to have an RMW instruction that does something to a
variable relative to a register that points to the per cpu base.

Thats generally possible. The problem is how expensive the RMW is going to
be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
