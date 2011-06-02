Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C8A266B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:36:22 -0400 (EDT)
Date: Thu, 2 Jun 2011 23:35:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602213553.GE2802@random.random>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602143143.GI23047@sequoia.sous-sol.org>
 <20110602143622.GE19505@random.random>
 <20110602153641.GJ23047@sequoia.sous-sol.org>
 <20110602164458.GG19505@random.random>
 <20110602201501.GC4114@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602201501.GC4114@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Chris Wright <chrisw@sous-sol.org>, CAI Qian <caiqian@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 02, 2011 at 10:15:01PM +0200, Andrea Righi wrote:
> I just tested this patch, but it doesn't seem to fix the problem, at
> least not the one I reported. The same bug happens again.

Yes I probably found another (not reproducible) bug that would lead to
a similar error, I'm waiting some other opinion on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
