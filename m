Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8F9946B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 13:24:25 -0500 (EST)
Date: Mon, 1 Mar 2010 19:23:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 32] update futex compound knowledge
Message-ID: <20100301182325.GA18837@random.random>
References: <patchbomb.1264969631@v2.random>
 <57877975a9a72d2fad7e.1264969635@v2.random>
 <1266319998.8404.48.camel@laptop>
 <20100301175846.GE17057@random.random>
 <1267466849.1579.38.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267466849.1579.38.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 07:07:29PM +0100, Peter Zijlstra wrote:
> On Mon, 2010-03-01 at 18:58 +0100, Andrea Arcangeli wrote:
> > 
> > But nothing risks to break at build time, simply any arch with
> > transparent hugepage support also has to implement
> > __get_user_pages_fast. Disabling irq and using __get_user_pages_fast
> > looked the best way to serialize against split_huge_page here (rather
> > than taking locks). 
> 
> PowerPC uses rcu-free'd pagetables for gup_fast() iirc, so no need to
> disable IRQs there.

btw, powerpc right now doesn't support transparent hugepages. IRQs
have to be disabled to stop pmdp_splitting_flush_notify on x86, for
the same reason why x86 has to disable irq in gup-fast.

I surely can try to abstract it before there is a second arch
involved, but it'd be more natural in the process of porting to an
arch that wants rcu_read_lock instead of local_irq_disable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
