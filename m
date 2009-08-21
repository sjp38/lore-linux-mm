Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 21CF16B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 14:41:17 -0400 (EDT)
Date: Fri, 21 Aug 2009 20:41:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH mmotm] ksm: antidote to MADV_MERGEABLE HWPOISON
Message-ID: <20090821184112.GB18623@basil.fritz.box>
References: <Pine.LNX.4.64.0908211912330.14259@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908211912330.14259@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Chris Zankel <chris@zankel.net>, Rik van RIel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Avi Kivity <avi@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 21, 2009 at 07:30:15PM +0100, Hugh Dickins wrote:
> linux-next is now sporting MADV_HWPOISON at 12, which would have a very
> nasty effect on KSM if you had CONFIG_MEMORY_FAILURE=y with CONFIG_KSM=y.
> Shift MADV_MERGEABLE and MADV_UNMERGEABLE down two - two to reduce the
> confusion if old and new userspace and kernel are mismatched.
> 
> Personally I'd prefer the MADV_HWPOISON testing feature to shift; but
> linux-next comes first in the mmotm lineup, and I can't be sure that
> madvise KSM already has more users than there are HWPOISON testers:
> so unless Andi is happy to shift MADV_HWPOISON, mmotm needs this.

Thanks for catching.

Shifting is fine, but I would prefer then if it was to some
value that is not reused (like 100) so that I can probe for it 
in the test programs.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
