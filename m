Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id BECE86B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 08:19:08 -0500 (EST)
Message-ID: <4F3A5F0B.2090309@redhat.com>
Date: Tue, 14 Feb 2012 15:18:03 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <4F2AB66C.2030309@redhat.com> <20120202170134.GM2518@linux.vnet.ibm.com> <4F2AC69B.7000704@redhat.com> <20120202175155.GV2518@linux.vnet.ibm.com> <4F2E7311.8060808@redhat.com> <20120205165927.GH2467@linux.vnet.ibm.com> <20120209152155.GA22552@somewhere.redhat.com> <4F33EEB3.4080807@redhat.com> <20120209182216.GG22552@somewhere.redhat.com> <20120209234144.GC2458@linux.vnet.ibm.com> <20120210013911.GM22552@somewhere.redhat.com>
In-Reply-To: <20120210013911.GM22552@somewhere.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 02/10/2012 03:39 AM, Frederic Weisbecker wrote:
> > 
> > As long as the code doesn't enter RCU read-side critical sections in
> > the time between rcu_idle_enter() and rcu_idle_exit(), this should
> > work fine.
>
> This should work fine yeah but further the correctness, I wonder if this
> is going to be a win.
>
> We use rcu_idle_enter() in idle to avoid to keep the tick for RCU. But
> what about falling into guest mode? I guess the tick is kept there
> so is it going to be a win in throughput or something to use rcu_idle_enter()?

We could disable the tick while in guest mode as well.  Interrupts in
guest mode are even more expensive than interrupts in user mode.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
