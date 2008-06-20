Subject: Re: [Experimental][PATCH] putback_lru_page rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1213981843.6474.68.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213813266.6497.14.camel@lts-notebook>
	 <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213886722.6398.29.camel@lts-notebook>
	 <20080620101352.e1200b8e.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213981843.6474.68.camel@lts-notebook>
Content-Type: text/plain
Date: Fri, 20 Jun 2008 16:41:29 -0400
Message-Id: <1213994489.6474.127.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-20 at 13:10 -0400, Lee Schermerhorn wrote:
> On Fri, 2008-06-20 at 10:13 +0900, KAMEZAWA Hiroyuki wrote:
> > Lee-san, this is an additonal one..
> > Not-tested-yet, just by review.
> 
> OK, I'll test this on my x86_64 platform, which doesn't seem to hit the
> soft lockups.
> 

Quick update:  

With this patch applied, at ~ 1.5 hours into the test, my system panic'd
[panic_on_oops set] with a BUG in __find_get_block() -- looks like the
BUG_ON() in check_irqs_on() called from bh_lru_install() inlined by
__find_get_block().  Before the panic occurred, I saw warnings from
native_smp_call_function_mask() [arch/x86/kernel/smp.c]--also because
irqs_disabled().

I'll back out the changes [spin_[un]lock() => spin_[un]lock_irq()] to
shrink_inactive_list() and try again.  Just a hunch.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
