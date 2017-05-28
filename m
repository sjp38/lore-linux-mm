Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 938CD6B0292
	for <linux-mm@kvack.org>; Sun, 28 May 2017 13:37:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s94so30607829ioe.14
        for <linux-mm@kvack.org>; Sun, 28 May 2017 10:37:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z67sor1062098itb.23.2017.05.28.10.37.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 May 2017 10:37:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170528081541.GE22193@infradead.org>
References: <1495829844-69341-1-git-send-email-keescook@chromium.org>
 <1495829844-69341-9-git-send-email-keescook@chromium.org> <20170528081541.GE22193@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 28 May 2017 10:37:26 -0700
Message-ID: <CAGXu5jKYHVWUnLpMn4Ef9S=0hCX-hh0h_UGuV7+a_jz5v68mFQ@mail.gmail.com>
Subject: Re: [PATCH v2 08/20] randstruct: Whitelist NIU struct page overloading
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S . Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

[trying again with correct linux-mm address...]

On Sun, May 28, 2017 at 1:15 AM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> On Fri, May 26, 2017 at 01:17:12PM -0700, Kees Cook wrote:
>> The NIU ethernet driver intentionally stores a page struct pointer on
>> top of the "mapping" field. Whitelist this case:
>>
>> drivers/net/ethernet/sun/niu.c: In function =E2=80=98niu_rx_pkt_ignore=
=E2=80=99:
>> drivers/net/ethernet/sun/niu.c:3402:10: note: found mismatched ssa struc=
t pointer types: =E2=80=98struct page=E2=80=99 and =E2=80=98struct address_=
space=E2=80=99
>>
>>     *link =3D (struct page *) page->mapping;
>>     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> The driver really needs to stop doing this anyway.  It would be good
> to send this out to linux-mm and netdev to come up with a better scheme.

Added to To. :) I couldn't understand why it was doing what it was
doing, hence the whitelist entry.

-Kees

--=20
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
