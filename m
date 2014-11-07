Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 94C9D6B00CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 01:43:42 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id ex7so3592821wid.10
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 22:43:42 -0800 (PST)
Subject: Re: [fuse-devel] [PATCH v5 7/7] add a flag for per-operation O_DSYNC semantics
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
From: Anton Altaparmakov <aia21@cam.ac.uk>
In-Reply-To: <CAFboF2y2skt=H4crv54shfnXOmz23W-shYWtHWekK8ZUDkfP=A@mail.gmail.com>
Date: Fri, 7 Nov 2014 08:43:00 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <B92AEADD-B22C-4A4A-B64D-96E8869D3282@cam.ac.uk>
References: <cover.1415220890.git.milosz@adfin.com> <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com> <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com> <BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk> <CAFboF2y2skt=H4crv54shfnXOmz23W-shYWtHWekK8ZUDkfP=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anand Avati <avati@gluster.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-arch@vger.kernel.org, linux-aio@kvack.org, linux-nfs@vger.kernel.org, Volker Lendecke <Volker.Lendecke@sernet.de>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, linux-api@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Tejun Heo <tj@kernel.org>, Milosz Tanski <milosz@adfin.com>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, ceph-devel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com, Mel Gorman <mgorman@suse.de>

Hi,

> On 7 Nov 2014, at 07:52, Anand Avati <avati@gluster.org> wrote:
> On Thu, Nov 6, 2014 at 8:22 PM, Anton Altaparmakov <aia21@cam.ac.uk> =
wrote:
> > On 7 Nov 2014, at 01:46, Jeff Moyer <jmoyer@redhat.com> wrote:
> > Minor nit, but I'd rather read something that looks like this:
> >
> >       if (type =3D=3D READ && (flags & RWF_NONBLOCK))
> >               return -EAGAIN;
> >       else if (type =3D=3D WRITE && (flags & RWF_DSYNC))
> >               return -EINVAL;
>=20
> But your version is less logically efficient for the case where "type =
=3D=3D READ" is true and "flags & RWF_NONBLOCK" is false because your =
version then has to do the "if (type =3D=3D WRITE" check before =
discovering it does not need to take that branch either, whilst the =
original version does not have to do such a test at all.
>=20
> Seriously?

Of course seriously.

> Just focus on the code readability/maintainability which makes the =
code most easily understood/obvious to a new pair of eyes, and leave =
such micro-optimizations to the compiler..

The original version is more readable (IMO) and this is not a =
micro-optimization.  It is people like you who are responsible for the =
fact that we need faster and faster computers to cope with the =
inefficient/poor code being written more and more...

And I really wouldn't hedge my bets on gcc optimizing something like =
that.  The amount of crap assembly produced from gcc that I have seen =
over the years suggests that it is quite likely it will make a hash of =
it instead...

Best regards,

	Anton

> Thanks

--=20
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
University of Cambridge Information Services, Roger Needham Building
7 JJ Thomson Avenue, Cambridge, CB3 0RB, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
