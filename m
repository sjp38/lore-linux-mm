Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFC76B000C
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:04:52 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id d3so370535uap.11
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:04:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3sor15247151vso.94.2018.11.02.05.04.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 05:04:51 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia> <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard>
In-Reply-To: <20181015003139.GZ6311@dastard>
Reply-To: fdmanana@gmail.com
From: Filipe Manana <fdmanana@gmail.com>
Date: Fri, 2 Nov 2018 12:04:39 +0000
Message-ID: <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.co=
m> wrote:
> > >
> > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > >
> > > A deduplication data corruption is exposed by fstests generic/505 on
> > > XFS.
> >
> > (and btrfs)
> >
> > Btw, the generic test I wrote was indeed numbered 505, however it was
> > never committed and there's now a generic/505 which has nothing to do
> > with deduplication.
> > So you should update the changelog to avoid confusion.
>
> What test is it now? And if it hasn't been committed, are you going
> to update it and repost as it clearly had value....

Sorry, I lost track of this.

So what was the conclusion of the thread where discussion about this
problem started?
It wasn't clear to me if a consensus was reached and got lost on that
long user space dedupe tools discussion between you and Zygo.

The test assumed a fix of rounding down the range and deduping less
bytes then requested (which ended up included in 4.19 for btrfs).

>From this vfs patch it seems it was decided to return errno -EDADE instead.
Is this the final decision?

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
