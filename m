Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEDA6B008C
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 18:44:00 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o9BMhwh8026287
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 15:43:58 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by hpaq6.eem.corp.google.com with ESMTP id o9BMhvVT019948
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 15:43:57 -0700
Received: by qwj8 with SMTP id 8so2115239qwj.8
        for <linux-mm@kvack.org>; Mon, 11 Oct 2010 15:43:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101011152534.6cf01208.akpm@linux-foundation.org>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-3-git-send-email-walken@google.com>
	<4CAB628D.3030205@redhat.com>
	<AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
	<20101008043956.GA25662@google.com>
	<4CAF1B90.3080703@redhat.com>
	<AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
	<20101009012204.GA17458@google.com>
	<20101011152534.6cf01208.akpm@linux-foundation.org>
Date: Mon, 11 Oct 2010 15:43:56 -0700
Message-ID: <AANLkTi=cm8jQ5hY5qVA0bUvVemUGJvx-_B7-1sexGkvB@mail.gmail.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 11, 2010 at 3:25 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> Replacement patches are a bit cruel to people who've already reviewed
> the previous version. =A0I always turn them into deltas so I can see what
> was changed. =A0It is below.

Thanks Andrew. Sorry for the trouble, I'll know to avoid this next time.

> How well was the new swapin path tested?

Not as well as the file backed path - it's not gotten real production
use yet. However the plan is that this change will be in google's next
kernel update, so it will get a lot more more testing soon (starting
in ~1 week).

I did basic testing by dirtying an anon VMA larger that memory, then
accessing it in random order while another thread runs a mmap/munmap
loop, and checking that things behave as expected there (i.e. the
patch allows the mmap/munmap thread to progress without waiting for
the other thread swap-ins).

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
