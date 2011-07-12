Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C4CE36B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 08:42:31 -0400 (EDT)
Subject: Re: [PATCH 0/4] mm, sparc64: Implement gup_fast()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110712122608.938583937@chello.nl>
References: <20110712122608.938583937@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 12 Jul 2011 14:42:11 +0200
Message-ID: <1310474531.14978.29.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>

On Tue, 2011-07-12 at 14:26 +0200, Peter Zijlstra wrote:
> With the recent mmu_gather changes that included generic RCU freeing of
> page-tables, it is now quite straight forward to implement gup_fast() on
> sparc64.
>=20
> Andrew, please consider merging these patches.

Gah, quilt-mail ate all the From: headers again.. all 4 patches are in
fact written by davem. Do you want a resend?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
