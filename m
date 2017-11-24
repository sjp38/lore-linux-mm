Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2A16B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 14:48:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y42so14034864wrd.23
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 11:48:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w4sor8183680wrc.64.2017.11.24.11.48.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Nov 2017 11:48:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2627399.jpLCoM7KBo@merkaba>
References: <20171122210739.29916-1-willy@infradead.org> <3543098.x2GeNdvaH7@merkaba>
 <20171124170307.GA681@bombadil.infradead.org> <2627399.jpLCoM7KBo@merkaba>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 24 Nov 2017 11:48:49 -0800
Message-ID: <CALvZod7dZuHrCavL985j1MqeJ_bUT8Fnz5UhTwHzF_+vcwJ6dA@mail.gmail.com>
Subject: Re: XArray documentation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <martin@lichtvoll.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Nov 24, 2017 at 10:01 AM, Martin Steigerwald
<martin@lichtvoll.de> wrote:
> Hi Matthew.
>
> Matthew Wilcox - 24.11.17, 18:03:
>> On Fri, Nov 24, 2017 at 05:50:41PM +0100, Martin Steigerwald wrote:
>> > Matthew Wilcox - 24.11.17, 02:16:
>> > > =3D=3D=3D=3D=3D=3D
>> > > XArray
>> > > =3D=3D=3D=3D=3D=3D
>> > >
>> > > Overview
>> > > =3D=3D=3D=3D=3D=3D=3D=3D
>> > >
>> > > The XArray is an array of ULONG_MAX entries.  Each entry can be eith=
er
>> > > a pointer, or an encoded value between 0 and LONG_MAX.  It is effici=
ent
>> > > when the indices used are densely clustered; hashing the object and
>> > > using the hash as the index will not perform well.  A
>> > > freshly-initialised
>> > > XArray contains a NULL pointer at every index.  There is no differen=
ce
>> > > between an entry which has never been stored to and an entry which h=
as
>> > > most
>> > > recently had NULL stored to it.
>> >
>> > I am no kernel developer (just provided a tiny bit of documentation a =
long
>> > time ago)=E2=80=A6 but on reading into this, I missed:
>> >
>> > What is it about? And what is it used for?
>> >
>> > "Overview" appears to be already a description of the actual
>> > implementation
>> > specifics, instead of=E2=80=A6 well an overview.
>> >
>> > Of course, I am sure you all know what it is for=E2=80=A6 but someone =
who wants to
>> > learn about the kernel is likely to be confused by such a start.
> [=E2=80=A6]
>> Thank you for your comment.  I'm clearly too close to it because even
>> after reading your useful critique, I'm not sure what to change.  Please
>> help me!
>
> And likely I am too far away to and do not understand enough of it to pro=
vide
> more concrete suggestions, but let me try. (I do understand some programm=
ing
> stuff like what an array is, what a pointer what an linked list or a tree=
 is
> or=E2=80=A6 so I am not completely novice here. I think the documentation=
 should not
> cover any of these basics.)
>
>> Maybe it's that I've described the abstraction as if it's the
>> implementation and put too much detail into the overview.  This might
>> be clearer?
>>
>> The XArray is an abstract data type which behaves like an infinitely
>> large array of pointers.  The index into the array is an unsigned long.
>> A freshly-initialised XArray contains a NULL pointer at every index.
>
> Yes, I think this is clearer already.
>
> Maybe with a few sentences on "Why does the kernel provide this?", "Where=
 is
> it used?" (if already known), "What use case is it suitable for =E2=80=93=
 if I want to
> implement something into the kernel (or in user space?) ?" and probably "=
How
> does it differ from user data structures the kernel provides?"
>

Adding on to Martin's questions. Basically what is the motivation
behind it? It seems like a replacement for radix tree, so, it would be
good to write why radix tree was not good enough or which use cases
radix tree could not solve. Also how XArray solves those
issues/use-cases? And if you know which scenarios or use-cases where
XArray will not be an optimal solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
