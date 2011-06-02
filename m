Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 718446B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:36:51 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:36:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602143622.GE19505@random.random>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602143143.GI23047@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602143143.GI23047@sequoia.sous-sol.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: CAI Qian <caiqian@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 02, 2011 at 07:31:43AM -0700, Chris Wright wrote:
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

echo 0 >scan_millisecs helps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
