Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B099B6B031E
	for <linux-mm@kvack.org>; Wed, 16 May 2018 07:18:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g92-v6so285953plg.6
        for <linux-mm@kvack.org>; Wed, 16 May 2018 04:18:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k9-v6si1941159pgo.340.2018.05.16.04.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 May 2018 04:18:55 -0700 (PDT)
Date: Wed, 16 May 2018 04:18:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/14] orangefs: don't return errno values from ->fault
Message-ID: <20180516111851.GA20670@bombadil.infradead.org>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516054348.15950-2-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:35AM +0200, Christoph Hellwig wrote:
> +	rc = orangefs_inode_getattr(file->f_mapping->host, 0, 1, STATX_SIZE);
>  	if (rc) {
>  		gossip_err("%s: orangefs_inode_getattr failed, "
>  		    "rc:%d:.\n", __func__, rc);
> -		return rc;
> +		return VM_FAULT_SIGBUS;

Nope.  orangefs_inode_getattr can return -ENOMEM.

>  	}
>  	return filemap_fault(vmf);
>  }
> -- 
> 2.17.0
> 
