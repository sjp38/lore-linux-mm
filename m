Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35F2E6B007B
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 13:02:19 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o8JH1gEA010657
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 10:01:43 -0700
Received: by iwn33 with SMTP id 33so5021650iwn.14
        for <linux-mm@kvack.org>; Sun, 19 Sep 2010 10:01:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100918155652.684071800@chello.nl>
References: <20100918155326.478277313@chello.nl> <20100918155652.684071800@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 19 Sep 2010 10:01:12 -0700
Message-ID: <AANLkTikkVZEGS=1_qbwPoG47twdbzrgWa85NEVD3TxMK@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm: stack based kmap_atomic
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 18, 2010 at 8:53 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
>
> =A0usr/src/linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c | 6832 ------=
---------
> =A029 files changed, 361 insertions(+), 7195 deletions(-)

What's that odd 'usr/src/linux-2.6' file that you have and removed?

You're using some seriously broken SCM there.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
