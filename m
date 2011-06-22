Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 28EEF6B01A6
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:43:08 -0400 (EDT)
Date: Tue, 21 Jun 2011 17:42:48 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 1/2 V2] ksm: take dirty bit as reference to avoid
 volatile pages scanning
Message-ID: <20110622004248.GR25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212126.06726.nai.xia@gmail.com>
 <20110621214233.GN25383@sequoia.sous-sol.org>
 <201106220802.35349.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106220802.35349.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

* Nai Xia (nai.xia@gmail.com) wrote:
> On Wednesday 22 June 2011 05:42:33 you wrote:
> > * Nai Xia (nai.xia@gmail.com) wrote:
> > > This patch makes the page_check_address() can validate if a subpage is
> > > in its place in a huge page pointed by the address. This can be useful when
> > > ksm does not split huge pages when looking up the subpages one by one.
> > 
> > Just a quick heads up...this patch does not compile by itself.  Could you
> > do a little patch cleanup?  Start with just making sure the Subject: is
> > correct for each patch.  Then make sure the 3 are part of same series.
> > And finally, make sure each is stand alone and complilable on its own.
> 
> Oh, indeed, there is a kvm & mmu_notifier related patch not named in a series.
> But with a same email thread ID, I think

Right, in same thread, but it ends up with:

[PATCH 1/2] ksm: take dirty bit as reference to avoid volatile pages...
[PATCH] mmu_notifier, kvm: Introduce dirty bit...
[PATCH 2/2] ksm: take dirty bit as reference to avoid volatile pages...

Not a big deal, but also easy to fix up ;)

> .... I had thought it's ok...
> I'll reformat this patch set to fullfill these requirements. 

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
