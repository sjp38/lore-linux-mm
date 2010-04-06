Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 965826B01E3
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 13:42:33 -0400 (EDT)
Date: Tue, 6 Apr 2010 18:46:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406164625.GZ5825@random.random>
References: <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <20100406093021.GC17882@csn.ul.ie>
 <BAA2AB49-DE66-4F22-B0E2-296522C2AF3E@mit.edu>
 <20100406111619.GD17882@csn.ul.ie>
 <13812DAC-4B53-4B6B-8725-EBC9E735AF96@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13812DAC-4B53-4B6B-8725-EBC9E735AF96@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 09:13:20AM -0400, Theodore Ts'o wrote:
> 
> On Apr 6, 2010, at 7:16 AM, Mel Gorman wrote:
> 
> > 
> > Does this clarify why min_free_kbytes helps and why the "recommended"
> > value is what it is?
> 
> Thanks, this is really helpful.   I wonder if it might be a good idea to have a boot command-line option which automatically sets vm.min_free_kbytes to the right value?   Most administrators who are used to using hugepages, are most familiar with needing to set boot command-line options, and this way they won't need to try to find this new userspace utility.   I was looking for hugeadm on Ubuntu, for example, and I couldn't find it.

It's part of libhugetlbfs. I also suggested in a earlier email this
would better be "echo 1
>/sys/kernel/vm/set-recommended-min_free_kbytes" or
set-recommended-min_free_kbytes=1 at boot considering it's a 10 liner
piece of code that does the math to set it. But it's no big deal on my
side, the important thing is that we have that feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
