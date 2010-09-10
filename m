Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6F46B00BB
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 17:50:28 -0400 (EDT)
Date: Fri, 10 Sep 2010 23:50:22 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
Message-ID: <20100910235022.74ec04de@basil.nowhere.org>
In-Reply-To: <AANLkTikV9nXxMW8X9Wq+wGaJfzMEAmzTFrDNf8Aq4cTs@mail.gmail.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<AANLkTikV9nXxMW8X9Wq+wGaJfzMEAmzTFrDNf8Aq4cTs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Sep 2010 10:19:24 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Sep 9, 2010 at 9:23 PM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > This patch applies Andrea's fix given by the following patch into
> > hugepage rmapping code:
> >
> > =C2=A0commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
> > =C2=A0Author: Andrea Arcangeli <aarcange@redhat.com>
> > =C2=A0Date: =C2=A0 Mon Aug 9 17:19:09 2010 -0700
> >
> > This patch uses anon_vma->root and avoids unnecessary overwriting
> > when anon_vma is already set up.
>=20
> Btw, why isn't the code in __page_set_anon_rmap() also doing this
> cleaner version (ie a single "if (PageAnon(page)) return;" up front)?

Perhaps I misunderstand the question, but __page_set_anon_rmap
should handle Anon pages, shouldn't it?

>=20
> The comments in that function are also some alien language translated
> to english by some broken automatic translation service. Could
> somebody clean up that function and come up with a comment that
> actually parses as English and makes sense?

I'll do that.

-Andi


--=20
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
