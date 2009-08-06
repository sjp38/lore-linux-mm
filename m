Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 926DD6B005D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:16:23 -0400 (EDT)
Date: Thu, 6 Aug 2009 12:15:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806101553.GP23385@random.random>
References: <20090805024058.GA8886@localhost>
 <20090805155805.GC23385@random.random>
 <4A79C486.1010809@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A79C486.1010809@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 01:42:30PM -0400, Rik van Riel wrote:
> Andrea Arcangeli wrote:
> > On Wed, Aug 05, 2009 at 10:40:58AM +0800, Wu Fengguang wrote:
> >>  			 */
> >> -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> >> +			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
> >>  				list_add(&page->lru, &l_active);
> >>  				continue;
> >>  			}
> >>
> > 
> > Please nuke the whole check and do an unconditional list_add;
> > continue; there.
> 
> <riel> aa: so you're saying we should _never_ add pages to the active 
> list at this point in the code
> <aa> right
> <riel> aa: and remove the list_add and continue completely
> <aa> yes
> <riel> aa: your email says the opposite :)

Posted more meaningful explanation in self-reply to the email that
said the opposite, which tries to explains why I changed my mind (well
my focus really was on VM_EXEC and I didn't change my mind about yet
but then I'm flexible so I'm listening if somebody thinks it's good
thing to keep it). The irc quote was greatly out of context and it
missed all the previous conversation... I hope my mail explains my
point in more detail than the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
