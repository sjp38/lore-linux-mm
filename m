Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 994436B000C
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:37:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v138-v6so19224944pgb.7
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:37:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d187-v6si17900291pfa.20.2018.10.17.01.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:37:24 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:37:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 19/26] vfs: clean up generic_remap_file_range_prep return
 value
Message-ID: <20181017083721.GG16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153966001458.3607.5940191707393894977.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153966001458.3607.5940191707393894977.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:20:14PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Since the remap prep function can update the length of the remap
> request, we can change this function to return the usual return status
> instead of the odd behavior it has now.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
