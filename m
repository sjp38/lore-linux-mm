Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB5336B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 00:44:51 -0400 (EDT)
Date: Fri, 3 Jun 2011 00:44:24 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1434914877.378198.1307076264791.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110602143143.GI23047@sequoia.sous-sol.org>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Righi <andrea@betterlinux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>



----- Original Message -----
> * CAI Qian (caiqian@redhat.com) wrote:
> > madvise(0x2210000, 4096, 0xc /* MADV_??? */) = 0
> > --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> 
> Right, that's just what the program is trying to do, segfault.
> 
> > +++ killed by SIGSEGV (core dumped) +++
> > Segmentation fault (core dumped)
> >
> > Did I miss anything?
> 
> I found it works but not 100% of the time.
> 
> So I just run the bug in a loop.
Still no luck here.
# while :; do ./test ; done
Segmentation fault (core dumped)
Segmentation fault (core dumped)
Segmentation fault (core dumped)
Segmentation fault (core dumped)
...

I can't really see what different with the hardware
here. It is only a NUMA server system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
