Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAC2D6B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 14:18:58 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id h39so754892uad.22
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 11:18:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h125sor17077665vkg.57.2018.11.02.11.18.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 11:18:57 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia> <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard> <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
 <20181102174229.GA4127@magnolia>
In-Reply-To: <20181102174229.GA4127@magnolia>
Reply-To: fdmanana@gmail.com
From: Filipe Manana <fdmanana@gmail.com>
Date: Fri, 2 Nov 2018 18:18:45 +0000
Message-ID: <CAL3q7H4MaphXQYnn3rRvc3YQZtiBBq1z61c91-LdNZZVzzLWJg@mail.gmail.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Fri, Nov 2, 2018 at 5:42 PM Darrick J. Wong <darrick.wong@oracle.com> wr=
ote:
>
> On Fri, Nov 02, 2018 at 12:04:39PM +0000, Filipe Manana wrote:
> > On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrot=
e:
> > >
> > > On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > > > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracl=
e.com> wrote:
> > > > >
> > > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > > >
> > > > > A deduplication data corruption is exposed by fstests generic/505=
 on
> > > > > XFS.
> > > >
> > > > (and btrfs)
> > > >
> > > > Btw, the generic test I wrote was indeed numbered 505, however it w=
as
> > > > never committed and there's now a generic/505 which has nothing to =
do
> > > > with deduplication.
> > > > So you should update the changelog to avoid confusion.
> > >
> > > What test is it now? And if it hasn't been committed, are you going
> > > to update it and repost as it clearly had value....
> >
> > Sorry, I lost track of this.
> >
> > So what was the conclusion of the thread where discussion about this
> > problem started?
> > It wasn't clear to me if a consensus was reached and got lost on that
> > long user space dedupe tools discussion between you and Zygo.
> >
> > The test assumed a fix of rounding down the range and deduping less
> > bytes then requested (which ended up included in 4.19 for btrfs).
> >
> > From this vfs patch it seems it was decided to return errno -EDADE inst=
ead.
> > Is this the final decision?
>
> No, I reworked the whole mess to match btrfs-4.19 behavior of deduping
> fewer bytes than requested.

What about cloning?
For cloning the issue is still not fixed in btrfs either.

So was that done in a later version of this patchset or somewhere else?

thanks

>
> --D
>
> > >
> > > Cheers,
> > >
> > > Dave.
> > > --
> > > Dave Chinner
> > > david@fromorbit.com
> >
> >
> >
> > --
> > Filipe David Manana,
> >
> > =E2=80=9CWhether you think you can, or you think you can't =E2=80=94 yo=
u're right.=E2=80=9D



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
