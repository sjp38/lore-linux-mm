Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED8CD600922
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 17:19:15 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o69LJEPR007851
	for <linux-mm@kvack.org>; Fri, 9 Jul 2010 14:19:14 -0700
Received: from vws10 (vws10.prod.google.com [10.241.21.138])
	by hpaq6.eem.corp.google.com with ESMTP id o69LJCkW027160
	for <linux-mm@kvack.org>; Fri, 9 Jul 2010 14:19:13 -0700
Received: by vws10 with SMTP id 10so3507826vws.21
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 14:19:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
References: <20100709002322.GO6197@random.random>
	<alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
Date: Fri, 9 Jul 2010 14:19:12 -0700
Message-ID: <AANLkTilUUDMp1U46M3GbGLtaMIkGaTtx0hBrnmRfSkJ4@mail.gmail.com>
Subject: Re: [PATCH] fix swapin race condition
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 9, 2010 at 1:32 PM, Hugh Dickins <hughd@google.com> wrote:
>
> There's a related bug of mine lurking here, only realized in looking
> through this, which you might want to fix at the same time: I should
> have moved the PageUptodate check from after the pte_same check to
> before the ksm_might_need_to_copy, shouldn't I? =C2=A0As it stands, we
> might copy junk from an invalid !Uptodate page into a clean new page.

Actually, not so, forget it: though it does look worrying, if the swap
page read had failed, leaving the page !Uptodate, then it would not
have been inserted into any address space in the first place,
page->mapping would remain unset, and ksm_might_need_to_copy() would
have no reason to copy it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
