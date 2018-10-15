Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0C76B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 20:31:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c28-v6so5203519pfe.4
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 17:31:44 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id q22-v6si8598274pgc.393.2018.10.14.17.31.42
        for <linux-mm@kvack.org>;
        Sun, 14 Oct 2018 17:31:43 -0700 (PDT)
Date: Mon, 15 Oct 2018 11:31:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Message-ID: <20181015003139.GZ6311@dastard>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia>
 <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Filipe Manana <fdmanana@gmail.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > A deduplication data corruption is exposed by fstests generic/505 on
> > XFS.
> 
> (and btrfs)
> 
> Btw, the generic test I wrote was indeed numbered 505, however it was
> never committed and there's now a generic/505 which has nothing to do
> with deduplication.
> So you should update the changelog to avoid confusion.

What test is it now? And if it hasn't been committed, are you going
to update it and repost as it clearly had value....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
