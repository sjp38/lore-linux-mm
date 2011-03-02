Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D110A8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 04:48:43 -0500 (EST)
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the
 same inode
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1102231448460.5732@sister.anvils>
References: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu>
	 <AANLkTimeihuzjgR2f7Avq2PJrCw1vZxtjh=wBPXO3aHP@mail.gmail.com>
	 <alpine.LSU.2.00.1102231448460.5732@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 02 Mar 2011 10:48:16 +0100
Message-ID: <1299059296.2428.13483.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, hch@infradead.org, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, rjw@sisk.pl, florian@mickler.org, trond.myklebust@fys.uio.no, maciej.rutecki@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2011-02-23 at 15:12 -0800, Hugh Dickins wrote:
>=20
> In his [2/8] mm: remove i_mmap_mutex lockbreak patch, Peter says
> "shouldn't hold up reclaim more than lock_page() would".  But (apart
> from a write error case) we always use trylock_page() in reclaim, we
> never dare hold it up on a lock_page().=20

D'0h! I so missed that, ok fixed up the changelog.

>  So page reclaim would get
> held up on truncation more than at present - though he's right to
> point out that truncation will usually be freeing pages much faster.

*phew* :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
