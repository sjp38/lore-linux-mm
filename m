Subject: Re: Re: [Experimental][PATCH] putback_lru_page rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <24280609.1213889550357.kamezawa.hiroyu@jp.fujitsu.com>
References: <1213886722.6398.29.camel@lts-notebook>
	 <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213813266.6497.14.camel@lts-notebook>
	 <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
	 <24280609.1213889550357.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 20 Jun 2008 12:24:19 -0400
Message-Id: <1213979059.6474.41.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-20 at 00:32 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
> >Subject: Re: [Experimental][PATCH] putback_lru_page rework
> >From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> >On Thu, 2008-06-19 at 09:22 +0900, KAMEZAWA Hiroyuki wrote:
> >> On Wed, 18 Jun 2008 14:21:06 -0400
> >> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> >> 
> >> > On Wed, 2008-06-18 at 18:40 +0900, KAMEZAWA Hiroyuki wrote:
> >> > > Lee-san, how about this ?
> >> > > Tested on x86-64 and tried Nisimura-san's test at el. works good now.
> >> > 
> >> > I have been testing with my work load on both ia64 and x86_64 and it
> >> > seems to be working well.  I'll let them run for a day or so.
> >> > 
> >> thank you.
> >> <snip>
> >
> >Update:
> >
> >On x86_64 [32GB, 4xdual-core Opteron], my work load has run for ~20:40
> >hours.  Still running.
> >
> >On ia64 [32G, 16cpu, 4 node], the system started going into softlockup
> >after ~7 hours.  Stack trace [below] indicates zone-lru lock in
> >__page_cache_release() called from put_page().  Either heavy contention
> >or failure to unlock.  Note that previous run, with patches to
> >putback_lru_page() and unmap_and_move(), the same load ran for ~18 hours
> >before I shut it down to try these patches.
> >
> Thanks, then there are more troubles should be shooted down.
> 
> 
> >I'm going to try again with the collected patches posted by Kosaki-san
> >[for which, Thanks!].  If it occurs again, I'll deconfig the unevictable
> >lru feature and see if I can reproduce it there.  It may be unrelated to
> >the unevictable lru patches.
> >
> I hope so...Hmm..I'll dig tomorrow. 

Another update--with the collected patches:

Again, the x86_64 ran for > 22 hours w/o error before I shut it down.

And, again, the ia64 went into soft lockup--same stack traces.  This
time after > 17 hours of running.  It is possible that a BUG started
this, but it has long scrolled out of my terminal buffer by the time I
see the system.

I'm now trying the ia64 platform with 26-rc5-mm3 + collected patches
with UNEVICTABLE_LRU de-configured.  I'll start that up today and let it
run over the weekend [with panic_on_oops set] if it hasn't hit the
problem before I leave.

Regards,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
