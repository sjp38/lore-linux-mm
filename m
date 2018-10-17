Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E83A26B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:26:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 17-v6so19169882pgs.18
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:26:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v2-v6si17141892pgc.570.2018.10.17.01.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:26:04 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:26:00 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/26] vfs: exit early from zero length remap operations
Message-ID: <20181017082600.GA16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153965942391.1256.1491987046439132016.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153965942391.1256.1491987046439132016.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:10:23PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> If a remap caller asks us to remap to the source file's EOF and the
> source file has zero bytes, exit early.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
