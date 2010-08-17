Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 781536B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 09:47:28 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC] [PATCH 2/4] dio: add page locking for direct I/O
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<alpine.DEB.2.00.1008110806070.673@router.home>
	<20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
	<20100812075941.GD6112@spritzera.linux.bs1.fc.nec.co.jp>
	<x49aaos3q2q.fsf@segfault.boston.devel.redhat.com>
	<20100816020737.GA19531@spritzera.linux.bs1.fc.nec.co.jp>
	<x49aaomheyi.fsf@segfault.boston.devel.redhat.com>
	<20100817081753.GA28762@spritzera.linux.bs1.fc.nec.co.jp>
Date: Tue, 17 Aug 2010 09:46:56 -0400
In-Reply-To: <20100817081753.GA28762@spritzera.linux.bs1.fc.nec.co.jp> (Naoya
	Horiguchi's message of "Tue, 17 Aug 2010 17:17:53 +0900")
Message-ID: <x4939uduzan.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> BTW, from the discussion with Christoph I noticed my misunderstanding
> about the necessity of additional page locking. It would seem that
> without page locking there is no danger of racing between direct I/O and
> page migration. So I retract this additional locking patch-set.

OK, great!  ;-)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
