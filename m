Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC288D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 05:45:07 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 18 Jan 2011 11:44:44 +0100
Message-ID: <1295347484.30950.495.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-17 at 23:12 -0800, Hugh Dickins wrote:
> 18/21 mutex-provide_mutex_is_contended.patch
>       I suppose so, though if we use it in the truncate path, then we are
>       stuck with the vm_truncate_count stuff I'd rather hoped would go aw=
ay;
>       but I guess you're right, that if we did spin_needbreak/need_lockbr=
eak
>       before, then we ought to do this now - though I suspect I only adde=
d
>       it because I had to insert a resched-point anyway, and it seemed a =
good
>       idea at the time to check lockbreak too since that had just been ad=
ded.=20

Like the other missed cleanups now possible, these are things we can
most definitely look at once the dust settles a bit. I just didn't want
to rewrite the world in one go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
