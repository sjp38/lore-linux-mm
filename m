Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED3096B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:52:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f13-v6so33398148wrr.4
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 21:52:57 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id q2-v6si8371187wmf.180.2018.10.21.21.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Oct 2018 21:52:55 -0700 (PDT)
Date: Mon, 22 Oct 2018 05:52:49 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Message-ID: <20181022045249.GP32577@ZenIV.linux.org.uk>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard>
 <20181022043741.GX6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022043741.GX6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 22, 2018 at 03:37:41PM +1100, Dave Chinner wrote:

> Ok, this is a bit of a mess. the patches do not merge cleanly to a
> 4.19-rc1 base kernel because of all the changes to
> include/linux/fs.h that have hit the tree after this. There's also
> failures against Documentation/filesystems/fs.h
> 
> IOWs, it's not going to get merged through the main XFS tree because
> I don't have the patience to resolve all the patch application
> failures, then when it comes to merge make sure all the merge
> failures end up being resolved correctly.
> 
> So if I take it through the XFS tree, it will being a standalone
> branch based on 4.19-rc8 and won't hit linux-next until after the
> first XFS merge when I can rebase the for-next branch...

How many conflicts does it have with XFS tree?  I can take it via
vfs.git...
