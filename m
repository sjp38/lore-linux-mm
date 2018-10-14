Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D69A6B000A
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:22:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d69-v6so12438587pgc.22
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:22:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 144-v6si8070889pgh.282.2018.10.14.10.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:22:40 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:22:37 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/25] vfs: pass remap flags to
 generic_remap_file_range_prep
Message-ID: <20181014172237.GF30673@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938921860.8361.1983470639945895613.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938921860.8361.1983470639945895613.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Fri, Oct 12, 2018 at 05:06:58PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Plumb the remap flags through the filesystem from the vfs function
> dispatcher all the way to the prep function to prepare for behavior
> changes in subsequent patches.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>

It seems like we should have passed this down earlier before all
the renaing and adding new helpers that could have easily started
out with the flags.
