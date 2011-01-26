Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1CB16B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 06:00:33 -0500 (EST)
Subject: Re: [PATCH 09/25] ia64: Preemptible mmu_gather
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4d3f3f522012086c15@agluck-desktop.sc.intel.com>
References: <4d3f3f522012086c15@agluck-desktop.sc.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 12:01:05 +0100
Message-ID: <1296039665.28776.1152.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: tony.luck@intel.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-01-25 at 13:23 -0800, tony.luck@intel.com wrote:
> Okay ... then could you swap out your part 09/25 for this version that
> has a #define and a comment.  You can add
>=20
> Acked-by: Tony Luck <tony.luck@intel.com>
>=20
Thanks Tony!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
