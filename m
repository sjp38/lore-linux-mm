Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5B66B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 13:42:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n5-v6so2385100plp.16
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 10:42:40 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g3-v6si35216128pgr.325.2018.11.02.10.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 10:42:39 -0700 (PDT)
Date: Fri, 2 Nov 2018 10:42:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Message-ID: <20181102174229.GA4127@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia>
 <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard>
 <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Filipe Manana <fdmanana@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Fri, Nov 02, 2018 at 12:04:39PM +0000, Filipe Manana wrote:
> On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> > > >
> > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > >
> > > > A deduplication data corruption is exposed by fstests generic/505 on
> > > > XFS.
> > >
> > > (and btrfs)
> > >
> > > Btw, the generic test I wrote was indeed numbered 505, however it was
> > > never committed and there's now a generic/505 which has nothing to do
> > > with deduplication.
> > > So you should update the changelog to avoid confusion.
> >
> > What test is it now? And if it hasn't been committed, are you going
> > to update it and repost as it clearly had value....
> 
> Sorry, I lost track of this.
> 
> So what was the conclusion of the thread where discussion about this
> problem started?
> It wasn't clear to me if a consensus was reached and got lost on that
> long user space dedupe tools discussion between you and Zygo.
> 
> The test assumed a fix of rounding down the range and deduping less
> bytes then requested (which ended up included in 4.19 for btrfs).
> 
> From this vfs patch it seems it was decided to return errno -EDADE instead.
> Is this the final decision?

No, I reworked the whole mess to match btrfs-4.19 behavior of deduping
fewer bytes than requested.

--D

> >
> > Cheers,
> >
> > Dave.
> > --
> > Dave Chinner
> > david@fromorbit.com
> 
> 
> 
> -- 
> Filipe David Manana,
> 
> a??Whether you think you can, or you think you can't a?? you're right.a??
