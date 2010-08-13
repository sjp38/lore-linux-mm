Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1BCE06B01F0
	for <linux-mm@kvack.org>; Fri, 13 Aug 2010 08:47:25 -0400 (EDT)
Date: Fri, 13 Aug 2010 07:47:21 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
In-Reply-To: <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
Message-ID: <alpine.DEB.2.00.1008130744550.27542@router.home>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1008110806070.673@router.home> <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Aug 2010, Naoya Horiguchi wrote:

> > Can you also avoid refcounts being increased during migration?
>
> Yes. I think this will be done in above-mentioned refactoring.

Thats not what I meant. Can you avoid other processors increasing
refcounts (direct I/O etc?) on any page struct of the huge page while
migration is running?

> This patch only handles migration under direct I/O.
> For the opposite (direct I/O under migration) it's not true.
> I wrote additional patches (later I'll reply to this email)
> for solving locking problem. Could you review them?

Sure.

> (Maybe these patches are beyond the scope of hugepage migration patch,
> so is it better to propose them separately?)

Migration with known races is really not what we want in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
