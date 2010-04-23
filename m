Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D4D456B01FE
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:28:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>
Date: Fri, 23 Apr 2010 09:26:33 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com 4BD1B626.7020702@redhat.com>
In-Reply-To: <4BD1B626.7020702@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > If a put returns zero, pseudo-RAM has rejected the data, and the page
> can
> > be written to swap as usual.
> >
> > Note that if a page is put and the page already exists in pseudo-RAM
> > (a "duplicate" put), either the put succeeds and the data is
> overwritten,
> > or the put fails AND the page is flushed.  This ensures stale data
> may
> > never be obtained from pseudo-RAM.
>=20
> Looks like "init" =3D=3D open, "put_page" =3D=3D write, "get_page" =3D=3D=
 read,
> "flush_page|flush_area" =3D=3D trim.  The only difference seems to be tha=
t
> an overwriting put_page may fail.  Doesn't seem to be much of a win,

No, ANY put_page can fail, and this is a critical part of the API
that provides all of the flexibility for the hypervisor and all
the guests. (See previous reply.)

The "duplicate put" semantics are carefully specified as there
are some coherency corner cases that are very difficult to handle
in the "backend" but very easy to handle in the kernel.  So the
specification explicitly punts these to the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
