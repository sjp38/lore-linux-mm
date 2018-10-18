Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC256B000C
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 01:03:50 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id c67-v6so18488791ywh.13
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 22:03:50 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j3-v6si6975846ybp.186.2018.10.17.22.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 22:03:49 -0700 (PDT)
Date: Wed, 17 Oct 2018 22:03:34 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 09/29] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181018050334.GU28243@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
 <153981631706.5568.6473120432728396978.stgit@magnolia>
 <20181018004826.GB12386@ZenIV.linux.org.uk>
 <20181018044718.GT28243@magnolia>
 <20181018045429.GF32577@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018045429.GF32577@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Thu, Oct 18, 2018 at 05:54:29AM +0100, Al Viro wrote:
> On Wed, Oct 17, 2018 at 09:47:18PM -0700, Darrick J. Wong wrote:
> 
> > > > +#define REMAP_FILE_DEDUP		(1 << 0)
> > > > +
> > > > +/*
> > > > + * These flags should be taken care of by the implementation (possibly using
> > > > + * vfs helpers) but can be ignored by the implementation.
> > > > + */
> > > > +#define REMAP_FILE_ADVISORY		(0)
> > > 
> > > ???
> > 
> > Sorry if this wasn't clear.  How about this?
> > 
> > /*
> >  * These flags signal that the caller is ok with altering various aspects of
> >  * the behavior of the remap operation.  The changes must be made by the
> >  * implementation; the vfs remap helper functions can take advantage of them.
> >  * Flags in this category exist to preserve the quirky behavior of the hoisted
> >  * btrfs clone/dedupe ioctls.
> >  */
> 
> Something like "currently we have no such flags, but some will appear
> in subsequent commits", removed once such flags do appear, perhaps?

Done.

--D
