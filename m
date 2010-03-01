Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 802206B0082
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 13:17:31 -0500 (EST)
Subject: Re: [PATCH 04 of 32] update futex compound knowledge
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100301175846.GE17057@random.random>
References: <patchbomb.1264969631@v2.random>
	 <57877975a9a72d2fad7e.1264969635@v2.random>
	 <1266319998.8404.48.camel@laptop>  <20100301175846.GE17057@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 01 Mar 2010 19:07:29 +0100
Message-ID: <1267466849.1579.38.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-01 at 18:58 +0100, Andrea Arcangeli wrote:
> 
> But nothing risks to break at build time, simply any arch with
> transparent hugepage support also has to implement
> __get_user_pages_fast. Disabling irq and using __get_user_pages_fast
> looked the best way to serialize against split_huge_page here (rather
> than taking locks). 

PowerPC uses rcu-free'd pagetables for gup_fast() iirc, so no need to
disable IRQs there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
