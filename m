Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A660A6B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 12:41:36 -0400 (EDT)
Date: Tue, 17 Aug 2010 11:41:52 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] [PATCH 2/4] dio: add page locking for direct I/O
In-Reply-To: <20100817142144.GB18161@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1008171140300.11174@router.home>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1008110806070.673@router.home> <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp> <20100812075941.GD6112@spritzera.linux.bs1.fc.nec.co.jp>
 <x49aaos3q2q.fsf@segfault.boston.devel.redhat.com> <20100816020737.GA19531@spritzera.linux.bs1.fc.nec.co.jp> <x49aaomheyi.fsf@segfault.boston.devel.redhat.com> <20100817081753.GA28762@spritzera.linux.bs1.fc.nec.co.jp> <x4939uduzan.fsf@segfault.boston.devel.redhat.com>
 <20100817142144.GB18161@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Andi Kleen wrote:

> On Tue, Aug 17, 2010 at 09:46:56AM -0400, Jeff Moyer wrote:
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> >
> > > BTW, from the discussion with Christoph I noticed my misunderstanding
> > > about the necessity of additional page locking. It would seem that
> > > without page locking there is no danger of racing between direct I/O and
> > > page migration. So I retract this additional locking patch-set.
> >
> > OK, great!  ;-)
>
> Well it sounds like we still may need something. It isn't good if O_DIRECT
> can starve (or DoS) migration.

Anything that increments a page refcount can interfere with migration and
cause migration to be aborted and retried later. Not something new. There
never was any guarantee that migration must succeed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
