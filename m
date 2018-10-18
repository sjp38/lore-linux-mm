Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFF66B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 00:54:37 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w17-v6so23369784wrt.0
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 21:54:37 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id o207-v6si3413596wme.97.2018.10.17.21.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 21:54:35 -0700 (PDT)
Date: Thu, 18 Oct 2018 05:54:29 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 09/29] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181018045429.GF32577@ZenIV.linux.org.uk>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
 <153981631706.5568.6473120432728396978.stgit@magnolia>
 <20181018004826.GB12386@ZenIV.linux.org.uk>
 <20181018044718.GT28243@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018044718.GT28243@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Wed, Oct 17, 2018 at 09:47:18PM -0700, Darrick J. Wong wrote:

> > > +#define REMAP_FILE_DEDUP		(1 << 0)
> > > +
> > > +/*
> > > + * These flags should be taken care of by the implementation (possibly using
> > > + * vfs helpers) but can be ignored by the implementation.
> > > + */
> > > +#define REMAP_FILE_ADVISORY		(0)
> > 
> > ???
> 
> Sorry if this wasn't clear.  How about this?
> 
> /*
>  * These flags signal that the caller is ok with altering various aspects of
>  * the behavior of the remap operation.  The changes must be made by the
>  * implementation; the vfs remap helper functions can take advantage of them.
>  * Flags in this category exist to preserve the quirky behavior of the hoisted
>  * btrfs clone/dedupe ioctls.
>  */

Something like "currently we have no such flags, but some will appear
in subsequent commits", removed once such flags do appear, perhaps?
