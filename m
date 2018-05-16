Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24ECC6B0328
	for <linux-mm@kvack.org>; Wed, 16 May 2018 08:58:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x7-v6so504201wrm.13
        for <linux-mm@kvack.org>; Wed, 16 May 2018 05:58:43 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 88-v6si2205624wrq.299.2018.05.16.05.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 05:58:42 -0700 (PDT)
Date: Wed, 16 May 2018 15:03:09 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: vm_fault_t conversion, for real
Message-ID: <20180516130309.GB32454@lst.de>
References: <20180516054348.15950-1-hch@lst.de> <20180516112347.GB20670@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516112347.GB20670@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 04:23:47AM -0700, Matthew Wilcox wrote:
> On Wed, May 16, 2018 at 07:43:34AM +0200, Christoph Hellwig wrote:
> > this series tries to actually turn vm_fault_t into a type that can be
> > typechecked and checks the fallout instead of sprinkling random
> > annotations without context.
> 
> Yes, why should we have small tasks that newcomers can do when the mighty
> Christoph Hellwig can swoop in and take over from them?  Seriously,
> can't your talents find a better use than this?

I've spent less time on this than trying to argue to you and Souptick
that these changes are only to get ignored and yelled at as an
"asshole maintainer".  So yes, I could have done more productive things
if you hadn't forced this escalation.
