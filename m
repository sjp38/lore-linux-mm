Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F19B6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 17:02:45 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 11so11932903wrb.18
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 14:02:45 -0800 (PST)
Received: from mail.lichtvoll.de (lichtvoll.de. [2001:67c:14c:12f::11:1])
        by mx.google.com with ESMTP id o10si7469751wrg.50.2017.11.24.14.02.42
        for <linux-mm@kvack.org>;
        Fri, 24 Nov 2017 14:02:42 -0800 (PST)
From: Martin Steigerwald <martin@lichtvoll.de>
Subject: Re: XArray documentation
Date: Fri, 24 Nov 2017 23:02:41 +0100
Message-ID: <7001154.REmHhS1LlQ@merkaba>
In-Reply-To: <20171124211809.GA17136@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org> <2627399.jpLCoM7KBo@merkaba> <20171124211809.GA17136@bombadil.infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

Matthew Wilcox - 24.11.17, 22:18:
> On Fri, Nov 24, 2017 at 07:01:31PM +0100, Martin Steigerwald wrote:
> > > The XArray is an abstract data type which behaves like an infinitely
> > > large array of pointers.  The index into the array is an unsigned lon=
g.
> > > A freshly-initialised XArray contains a NULL pointer at every index.
> >=20
> > Yes, I think this is clearer already.
> >=20
> > Maybe with a few sentences on "Why does the kernel provide this?", "Whe=
re
> > is it used?" (if already known), "What use case is it suitable for =E2=
=80=93 if I
> > want to implement something into the kernel (or in user space?) ?" and
> > probably "How does it differ from user data structures the kernel
> > provides?"
>=20
> OK, I think this is getting more useful.  Here's what I currently have:
>=20
> Overview
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The XArray is an abstract data type which behaves like a very large array
> of pointers.  It meets many of the same needs as a hash or a conventional
> resizable array.  Unlike a hash, it allows you to sensibly go to the
> next or previous entry in a cache-efficient manner.  In contrast to
> a resizable array, there is no need for copying data or changing MMU
> mappings in order to grow the array.  It is more memory-efficient,
> parallelisable and cache friendly than a doubly-linked list.  It takes
> advantage of RCU to perform lookups without locking.

I like this.

I bet I may not be able help much further with it other than to possibly=20
proofread it tomorrow.

Thank you for considering my suggestion.

=2D-=20
Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
