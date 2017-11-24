Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1249E6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 11:50:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y41so13944266wrc.22
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:50:46 -0800 (PST)
Received: from mail.lichtvoll.de (mondschein.lichtvoll.de. [194.150.191.11])
        by mx.google.com with ESMTP id t135si7288785wmd.247.2017.11.24.08.50.42
        for <linux-mm@kvack.org>;
        Fri, 24 Nov 2017 08:50:43 -0800 (PST)
From: Martin Steigerwald <martin@lichtvoll.de>
Subject: Re: XArray documentation
Date: Fri, 24 Nov 2017 17:50:41 +0100
Message-ID: <3543098.x2GeNdvaH7@merkaba>
In-Reply-To: <20171124011607.GB3722@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org> <20171124011607.GB3722@bombadil.infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

Hello Matthew.

Matthew Wilcox - 24.11.17, 02:16:
> =3D=3D=3D=3D=3D=3D
> XArray
> =3D=3D=3D=3D=3D=3D
>=20
> Overview
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The XArray is an array of ULONG_MAX entries.  Each entry can be either
> a pointer, or an encoded value between 0 and LONG_MAX.  It is efficient
> when the indices used are densely clustered; hashing the object and
> using the hash as the index will not perform well.  A freshly-initialised
> XArray contains a NULL pointer at every index.  There is no difference
> between an entry which has never been stored to and an entry which has mo=
st
> recently had NULL stored to it.

I am no kernel developer (just provided a tiny bit of documentation a long=
=20
time ago)=E2=80=A6 but on reading into this, I missed:

What is it about? And what is it used for?

"Overview" appears to be already a description of the actual implementation=
=20
specifics, instead of=E2=80=A6 well an overview.

Of course, I am sure you all know what it is for=E2=80=A6 but someone who w=
ants to=20
learn about the kernel is likely to be confused by such a start.

Thanks,
=2D-=20
Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
