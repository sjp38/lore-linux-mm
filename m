Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C24C66B0278
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:40:23 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q18-v6so782694pfk.3
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:40:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n25-v6si16773254pgl.508.2018.10.17.01.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:40:23 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:40:20 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 26/26] xfs: remove redundant remap partial EOF block
 checks
Message-ID: <20181017084020.GJ16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153966006214.3607.15131077363912605792.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153966006214.3607.15131077363912605792.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:21:02PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Now that we've moved the partial EOF block checks to the VFS helpers, we
> can remove the redundant functionality from XFS.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Dave Chinner <dchinner@redhat.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
