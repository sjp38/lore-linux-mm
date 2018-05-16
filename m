Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 884C66B0322
	for <linux-mm@kvack.org>; Wed, 16 May 2018 07:28:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b64-v6so288488pfl.13
        for <linux-mm@kvack.org>; Wed, 16 May 2018 04:28:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w5-v6si2425287plp.330.2018.05.16.04.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 May 2018 04:28:16 -0700 (PDT)
Date: Wed, 16 May 2018 04:28:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 14/14] mm: turn on vm_fault_t type checking
Message-ID: <20180516112813.GC20670@bombadil.infradead.org>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180516054348.15950-15-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:48AM +0200, Christoph Hellwig wrote:
> Switch vm_fault_t to point to an unsigned int with __bN?twise annotations.
> This both catches any old ->fault or ->page_mkwrite instance with plain
> compiler type checking, as well as finding more intricate problems with
> sparse.

Come on, Christoph; you know better than this.  This patch is completely
unreviewable.  Split it into one patch per maintainer tree, and in any
event, the patch to convert vm_fault_t to an unsigned int should be
separated from all the trivial conversions.
