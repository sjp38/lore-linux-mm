Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4646D90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:42:54 -0400 (EDT)
Date: Tue, 21 Jun 2011 14:42:33 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 1/2 V2] ksm: take dirty bit as reference to avoid
 volatile pages scanning
Message-ID: <20110621214233.GN25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212126.06726.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106212126.06726.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

* Nai Xia (nai.xia@gmail.com) wrote:
> This patch makes the page_check_address() can validate if a subpage is
> in its place in a huge page pointed by the address. This can be useful when
> ksm does not split huge pages when looking up the subpages one by one.

Just a quick heads up...this patch does not compile by itself.  Could you
do a little patch cleanup?  Start with just making sure the Subject: is
correct for each patch.  Then make sure the 3 are part of same series.
And finally, make sure each is stand alone and complilable on its own.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
