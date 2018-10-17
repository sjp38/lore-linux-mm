Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0F976B026E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:29:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c4-v6so20333135plz.20
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:29:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r9-v6si16577677pgi.569.2018.10.17.01.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:29:04 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:28:58 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/26] vfs: pass remap flags to
 generic_remap_file_range_prep
Message-ID: <20181017082858.GC16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153965947208.1256.13169150057249233851.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153965947208.1256.13169150057249233851.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:11:12PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Plumb the remap flags through the filesystem from the vfs function
> dispatcher all the way to the prep function to prepare for behavior
> changes in subsequent patches.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
