Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F97D9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 16:46:15 -0400 (EDT)
Date: Mon, 3 Oct 2011 15:46:11 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: lockdep recursive locking detected (rcu_kthread /
 __cache_free)
In-Reply-To: <20111003203139.GH2403@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1110031540560.11713@router.home>
References: <20111003175322.GA26122@sucs.org> <20111003203139.GH2403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Sitsofe Wheeler <sitsofe@yahoo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, 3 Oct 2011, Paul E. McKenney wrote:

> The first lock was acquired here in an RCU callback.  The later lock that
> lockdep complained about appears to have been acquired from a recursive
> call to __cache_free(), with no help from RCU.  This looks to me like
> one of the issues that arise from the slab allocator using itself to
> allocate slab metadata.

Right. However, this is a false positive since the slab cache with
the metadata is different from the slab caches with the slab data. The slab
cache with the metadata does not use itself any metadata slab caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
