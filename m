Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2E906B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:12:21 -0400 (EDT)
Date: Sun, 11 Apr 2010 14:11:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411121130.GD10952@elte.hu>
References: <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
 <20100411112424.GA10952@elte.hu>
 <4BC1B389.20803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1B389.20803@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> I would like to see transparent hugetlb enabled by default for all 
> workloads, and good enough so that users don't need to tweak it at all.  May 
> not happen for the initial merge, but certainly later.

Definitely agreed with that - the feature doesnt make sense without that kind 
of automatic default. Either it _can_ handle to be the default just fine and 
give us advantages on a broad basis, or if not then it's not worth merging.

Nevertheless allowing an opt-out on a finegrained basis would still be nice in 
general. The default is powerful enough of a force in itself - a finegrained 
opt-out does not hurt that advantage, it only improves utility.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
