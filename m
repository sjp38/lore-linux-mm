Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8736B0038
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 13:01:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a63so13969871wrc.1
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:01:34 -0800 (PST)
Received: from mail.lichtvoll.de (lichtvoll.de. [2001:67c:14c:12f::11:1])
        by mx.google.com with ESMTP id f22si6265064wmi.7.2017.11.24.10.01.32
        for <linux-mm@kvack.org>;
        Fri, 24 Nov 2017 10:01:32 -0800 (PST)
From: Martin Steigerwald <martin@lichtvoll.de>
Subject: Re: XArray documentation
Date: Fri, 24 Nov 2017 19:01:31 +0100
Message-ID: <2627399.jpLCoM7KBo@merkaba>
In-Reply-To: <20171124170307.GA681@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org> <3543098.x2GeNdvaH7@merkaba> <20171124170307.GA681@bombadil.infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

Hi Matthew.

Matthew Wilcox - 24.11.17, 18:03:
> On Fri, Nov 24, 2017 at 05:50:41PM +0100, Martin Steigerwald wrote:
> > Matthew Wilcox - 24.11.17, 02:16:
> > > =3D=3D=3D=3D=3D=3D
> > > XArray
> > > =3D=3D=3D=3D=3D=3D
> > >=20
> > > Overview
> > > =3D=3D=3D=3D=3D=3D=3D=3D
> > >=20
> > > The XArray is an array of ULONG_MAX entries.  Each entry can be either
> > > a pointer, or an encoded value between 0 and LONG_MAX.  It is efficie=
nt
> > > when the indices used are densely clustered; hashing the object and
> > > using the hash as the index will not perform well.  A
> > > freshly-initialised
> > > XArray contains a NULL pointer at every index.  There is no difference
> > > between an entry which has never been stored to and an entry which has
> > > most
> > > recently had NULL stored to it.
> >=20
> > I am no kernel developer (just provided a tiny bit of documentation a l=
ong
> > time ago)=E2=80=A6 but on reading into this, I missed:
> >=20
> > What is it about? And what is it used for?
> >=20
> > "Overview" appears to be already a description of the actual
> > implementation
> > specifics, instead of=E2=80=A6 well an overview.
> >=20
> > Of course, I am sure you all know what it is for=E2=80=A6 but someone w=
ho wants to
> > learn about the kernel is likely to be confused by such a start.
[=E2=80=A6]
> Thank you for your comment.  I'm clearly too close to it because even
> after reading your useful critique, I'm not sure what to change.  Please
> help me!

And likely I am too far away to and do not understand enough of it to provi=
de=20
more concrete suggestions, but let me try. (I do understand some programmin=
g=20
stuff like what an array is, what a pointer what an linked list or a tree i=
s=20
or=E2=80=A6 so I am not completely novice here. I think the documentation s=
hould not=20
cover any of these basics.)

> Maybe it's that I've described the abstraction as if it's the
> implementation and put too much detail into the overview.  This might
> be clearer?
>=20
> The XArray is an abstract data type which behaves like an infinitely
> large array of pointers.  The index into the array is an unsigned long.
> A freshly-initialised XArray contains a NULL pointer at every index.

Yes, I think this is clearer already.

Maybe with a few sentences on "Why does the kernel provide this?", "Where i=
s=20
it used?" (if already known), "What use case is it suitable for =E2=80=93 i=
f I want to=20
implement something into the kernel (or in user space?) ?" and probably "Ho=
w=20
does it differ from user data structures the kernel provides?"

I don=C2=B4t know whether the questions make sense to you. But that were qu=
estions=20
I had in mind as I read into your documentation. I do not think this needs =
to=20
be long or so=E2=80=A6 maybe just a few sentences that put XArray into a co=
ntext,=20
before diving into the details. I think that could help new developers who=
=20
want to learn about kernel development when they learn about XArray.

And then as you suggest all the important implementation details.

> ----
> and then move all this information into later paragraphs:
>=20
> There is no difference between an entry which has never been stored to
> and an entry which has most recently had NULL stored to it.
> Each entry in the array can be either a pointer, or an
> encoded value between 0 and LONG_MAX.
> While you can use any index, the implementation is efficient when the
> indices used are densely clustered; hashing the object and using the
> hash as the index will not perform well.

Yes.

And I notice now that you have some use case remarks in here=E2=80=A6 like =
"efficient=20
when densely clustered". I missed these initially.

Thanks,
=2D-=20
Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
