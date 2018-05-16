Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3D26B032C
	for <linux-mm@kvack.org>; Wed, 16 May 2018 09:13:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l85-v6so456898pfb.18
        for <linux-mm@kvack.org>; Wed, 16 May 2018 06:13:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c7-v6si2482330plo.47.2018.05.16.06.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 May 2018 06:13:08 -0700 (PDT)
Date: Wed, 16 May 2018 06:13:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 10/14] vgem: separate errno from VM_FAULT_* values
Message-ID: <20180516131304.GF20670@bombadil.infradead.org>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-11-hch@lst.de>
 <20180516095303.GH3438@phenom.ffwll.local>
 <20180516130159.GA32454@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516130159.GA32454@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 03:01:59PM +0200, Christoph Hellwig wrote:
> On Wed, May 16, 2018 at 11:53:03AM +0200, Daniel Vetter wrote:
> > Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> > 
> > Want me to merge this through drm-misc or plan to pick it up yourself?
> 
> For now I just want a honest discussion if people really actually
> want the vm_fault_t change with the whole picture in place.

That discussion already happened on the -mm mailing list.  And again
at LSFMM.  Both times the answer was yes.
