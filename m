Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A64EB6B004D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:12:53 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Wed, 5 Aug 2009 09:12:39 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E89326B651C0BD@azsmsx502.amr.corp.intel.com>
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com>
 <20090805160504.GD23385@random.random>
In-Reply-To: <20090805160504.GD23385@random.random>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> It can't distinguish. Besides the pages being refaulted (as minor
> faults) implies they weren't collected yet. So the fact they are
> allowed to stay on active list or not can't matter or alter the
> refaulting issue.

Sounds like there's some terminology confusion.  A refault is a page being =
discarded due to memory pressure and subsequently being faulted back in.  I=
 was counting the number of faults between the discard and faulting back in=
 for each affected page.  For a large number of predominately stack pages, =
that number was very small.

					Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
