Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 53EF894006D
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:50:29 -0400 (EDT)
Date: Tue, 4 Oct 2011 09:50:25 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: lockdep recursive locking detected (rcu_kthread /
 __cache_free)
In-Reply-To: <1317739225.32543.9.camel@twins>
Message-ID: <alpine.DEB.2.00.1110040948230.8522@router.home>
References: <20111003175322.GA26122@sucs.org>  <20111003203139.GH2403@linux.vnet.ibm.com>  <alpine.DEB.2.00.1110031540560.11713@router.home>  <20111003214739.GK2403@linux.vnet.ibm.com>  <alpine.DEB.2.00.1110040916330.8522@router.home>
 <1317739225.32543.9.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 4 Oct 2011, Peter Zijlstra wrote:

> It could of course be I got confused and broke stuff instead, could
> someone who knows slab (I guess that's either Pekka, Christoph or David)
> stare at those patches?

Why is the loop in init_lock_keys only running over kmalloc caches and not
over all slab caches? It seems that this has to be especially applied to
regular slab caches because those are the ones that mostly have off slab
structures. So modify init_lock_keys to run over all slab caches?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
