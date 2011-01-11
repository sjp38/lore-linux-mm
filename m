Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 585B36B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 21:29:33 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p0B2TV54022345
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 18:29:31 -0800
Received: from vws8 (vws8.prod.google.com [10.241.21.136])
	by wpaz13.hot.corp.google.com with ESMTP id p0B2TUtL018334
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 18:29:30 -0800
Received: by vws8 with SMTP id 8so9002172vws.26
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 18:29:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110111015742.GL9506@random.random>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
	<20110111015742.GL9506@random.random>
Date: Mon, 10 Jan 2011 18:29:29 -0800
Message-ID: <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 5:57 PM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> On Mon, Jan 10, 2011 at 04:55:53PM -0800, Hugh Dickins wrote:
>> If you configure THP in addition to HUGETLB_PAGE on x86_32 without PAE,
>> the p?d-folding works out that munlock_vma_pages_range() can crash to
>> follow_page()'s pud_huge() BUG_ON(flags & FOLL_GET): it needs the same
>> VM_HUGETLB check already there on the pmd_huge() line. =C2=A0Convenientl=
y,
>> openSUSE provides a "blogd" which tests this out at startup!
>
> How is THP related to this? pud_trans_huge doesn't exist, if pud_huge
> is true, vma is already guaranteed to belong to hugetlbfs without
> requiring the additional check.

THP puts in pmds that are huge.  In this configuration the "folding" is
such that the puds are the pmds.  So the pud_huge test passes and
the BUG_ON hits.  I hope I've explained that correctly, agreed that
it's confusing!

>
> I added the check to pmd_huge already, there it is needed, but for
> pud_huge it isn't as far as I can tell.

Crashing on that BUG_ON suggests otherwise ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
