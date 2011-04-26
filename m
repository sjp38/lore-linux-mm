Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 172CF9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:00:15 -0400 (EDT)
Date: Tue, 26 Apr 2011 15:00:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110426130004.GA27267@random.random>
References: <20110415101248.GB22688@suse.de>
 <BANLkTik7H+cmA8iToV4j1ncbQqeraCaeTg@mail.gmail.com>
 <20110421110841.GA612@suse.de>
 <20110421142636.GA1835@barrios-desktop>
 <20110421160057.GA28712@suse.de>
 <20110421161402.GS5611@random.random>
 <BANLkTi=+fGe-hrV3c8r2jKzWG2BHU0GsFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=+fGe-hrV3c8r2jKzWG2BHU0GsFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Fri, Apr 22, 2011 at 09:54:24AM +0900, Minchan Kim wrote:
> Before doing that, let's clear the point. You mentioned  it shouldn't
> be a common occurrence but you are suggesting we should do for code
> consistency POV. Am I right?

Yes, for code consistency and cleanup.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
