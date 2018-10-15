Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1DFB6B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:19:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s141-v6so15026035pgs.23
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:19:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q1-v6si918249plb.292.2018.10.15.11.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 11:19:17 -0700 (PDT)
Date: Mon, 15 Oct 2018 11:19:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/25] vfs: create generic_remap_file_range_touch to
 update inode metadata
Message-ID: <20181015181914.GA14558@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938921180.8361.13556945128095535605.stgit@magnolia>
 <20181014172131.GE30673@infradead.org>
 <20181015163001.GK28243@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015163001.GK28243@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 09:30:01AM -0700, Darrick J. Wong wrote:
> I originally thought "touch" because it updates [cm]time. :)
> 
> Though looking at the final code, I think this can just be called from
> the end of generic_remap_file_range_prep, so we can skip the export and
> all that other stuff.

I though about that, but the locking didn't seem to quite work out
between xfs and ocfs.

Nevermind the big elephant of actually converting btrfs to the "VFS"
helper - I think if that doesn't work out it is rather questionable
how generic they actually are.
