Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBC66B00A2
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:29:41 -0400 (EDT)
Date: Fri, 10 Sep 2010 16:30:04 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] hugetlb, rmap: fixes and cleanups
Message-ID: <20100910163004.5621dbc8@basil.nowhere.org>
In-Reply-To: <20100910114759.GA5687@hammershoi.dip.jp>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100910110438.6aaf181e@basil.nowhere.org>
	<20100910114759.GA5687@hammershoi.dip.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <nao.horiguchi@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Sep 2010 20:47:59 +0900
Naoya Horiguchi <nao.horiguchi@gmail.com> wrote:

> On Fri, Sep 10, 2010 at 11:04:38AM +0200, Andi Kleen wrote:
> > On Fri, 10 Sep 2010 13:23:02 +0900
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > Hi,
> > > 
> > > These are fix and cleanup patches for hugepage rmapping.
> > > All these were pointed out in the following thread (last 4
> > > messages.)
> > > 
> > >   http://thread.gmane.org/gmane.linux.kernel.mm/52334
> > 
> > Looks all good to me. It's not strictly hwpoison related
> > though, so I assume they are better with Andrew than my tree.
> 
> Agreed.
> 
> > I assume they do not depend on the earlier patchkit?
> 
> No, all changes on this patchset update code merged with
> "HWPOISON for hugepage" patchset.

Ok then it's better for me to carry it anyways, otherwise Andrew
will be in dependency hell.

I will need some acks from MM hackers though. Anyone?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
