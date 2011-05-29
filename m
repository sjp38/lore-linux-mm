Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5766B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 04:36:12 -0400 (EDT)
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1105281738530.14374@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
	 <1306617270.2497.516.camel@laptop>
	 <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
	 <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
	 <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
	 <BANLkTi=9qqiLNuo9qbcLoQtK3CKSPnhn4g@mail.gmail.com>
	 <alpine.LSU.2.00.1105281738530.14374@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 29 May 2011 10:35:31 +0200
Message-ID: <1306658131.1200.1226.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-05-28 at 17:43 -0700, Hugh Dickins wrote:
>=20
> And I'm increasingly confident that it's complete too, but it will be
> interesting to see whether I've persuaded Peter.  It was certainly a
> very good point that he raised, that I hadn't thought of at all.=20

Yes you have. And hopefully we've now got enough comments there serve us
next time..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
