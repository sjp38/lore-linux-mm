Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B584F6B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:24:05 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1295873131.28776.431.camel@laptop>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	 <1295457039.28776.137.camel@laptop>
	 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
	 <1295873131.28776.431.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 24 Jan 2011 15:24:44 +0100
Message-ID: <1295879084.28776.432.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-24 at 13:45 +0100, Peter Zijlstra wrote:
> The only significant loser, I think,
> > would be page reclaim (when concurrent with truncation): could spin for=
 a
> > long time waiting for the i_mmap_mutex it expects would soon be dropped=
?=20

Well it won't spin (much) but mostly go to sleep if it really takes very
long, but then, could it really take much longer than say a lock_page()
when reclaim hits a page under IO?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
