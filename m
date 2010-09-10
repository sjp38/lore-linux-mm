Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 041B36B00B9
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 13:25:39 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o8AHP8MK017466
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:25:08 -0700
Received: by iwn33 with SMTP id 33so3162670iwn.14
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:25:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Sep 2010 10:19:24 -0700
Message-ID: <AANLkTikV9nXxMW8X9Wq+wGaJfzMEAmzTFrDNf8Aq4cTs@mail.gmail.com>
Subject: Re: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 9, 2010 at 9:23 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This patch applies Andrea's fix given by the following patch into hugepag=
e
> rmapping code:
>
> =A0commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
> =A0Author: Andrea Arcangeli <aarcange@redhat.com>
> =A0Date: =A0 Mon Aug 9 17:19:09 2010 -0700
>
> This patch uses anon_vma->root and avoids unnecessary overwriting when
> anon_vma is already set up.

Btw, why isn't the code in __page_set_anon_rmap() also doing this
cleaner version (ie a single "if (PageAnon(page)) return;" up front)?

The comments in that function are also some alien language translated
to english by some broken automatic translation service. Could
somebody clean up that function and come up with a comment that
actually parses as English and makes sense?

                                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
