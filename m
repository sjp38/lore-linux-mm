Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 040F96B0271
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:29:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t10-v6so4832530plh.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:29:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v23-v6si16900706pgh.581.2018.10.17.01.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:29:49 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:29:45 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 12/26] vfs: pass remap flags to generic_remap_checks
Message-ID: <20181017082945.GD16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153965947897.1256.9976516083702922569.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153965947897.1256.9976516083702922569.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:11:19PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Pass the same remap flags to generic_remap_checks for consistency.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
