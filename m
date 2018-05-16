Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1ED66B0326
	for <linux-mm@kvack.org>; Wed, 16 May 2018 08:57:33 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so516585wrc.2
        for <linux-mm@kvack.org>; Wed, 16 May 2018 05:57:33 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g64-v6si1954754wmf.115.2018.05.16.05.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 05:57:32 -0700 (PDT)
Date: Wed, 16 May 2018 15:01:59 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 10/14] vgem: separate errno from VM_FAULT_* values
Message-ID: <20180516130159.GA32454@lst.de>
References: <20180516054348.15950-1-hch@lst.de> <20180516054348.15950-11-hch@lst.de> <20180516095303.GH3438@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516095303.GH3438@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 11:53:03AM +0200, Daniel Vetter wrote:
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> 
> Want me to merge this through drm-misc or plan to pick it up yourself?

For now I just want a honest discussion if people really actually
want the vm_fault_t change with the whole picture in place.
