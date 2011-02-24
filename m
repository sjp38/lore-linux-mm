Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CDCDD8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 07:38:12 -0500 (EST)
Subject: Re: [PATCH] mm: remove worrying dead code from find_get_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1102232127590.2239@sister.anvils>
References: <alpine.LSU.2.00.1102232127590.2239@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Feb 2011 13:38:00 +0100
Message-ID: <1298551080.2428.42.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Salman Qazi <sqazi@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2011-02-23 at 21:31 -0800, Hugh Dickins wrote:
> The radix_tree_deref_retry() case in find_get_pages() has a strange
> little excrescence, not seen in the other gang lookups: it looks like
> the start of an abandoned attempt to guarantee forward progress in a
> case that cannot arise.
>=20
> ret should always be 0 here: if it isn't, then going back to restart
> will leak references to pages already gotten.  There used to be a
> comment saying nr_found is necessarily 1 here: that's not quite true,
> but the radix_tree_deref_retry() case is peculiar to the entry at index
> 0, when we race with it being moved out of the radix_tree root or back.
>=20
> Remove the worrisome two lines, add a brief comment here and in
> find_get_pages_contig() and find_get_pages_tag(), and a WARN_ON
> in find_get_pages() should it ever be seen elsewhere than at 0.
>=20
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
