Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A297D6B032E
	for <linux-mm@kvack.org>; Wed, 16 May 2018 09:23:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 72-v6so460798pld.19
        for <linux-mm@kvack.org>; Wed, 16 May 2018 06:23:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c8-v6si2683750pfj.138.2018.05.16.06.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 May 2018 06:22:59 -0700 (PDT)
Date: Wed, 16 May 2018 06:22:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: vm_fault_t conversion, for real
Message-ID: <20180516132256.GG20670@bombadil.infradead.org>
References: <20180516054348.15950-1-hch@lst.de>
 <20180516112347.GB20670@bombadil.infradead.org>
 <20180516130309.GB32454@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516130309.GB32454@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 03:03:09PM +0200, Christoph Hellwig wrote:
> On Wed, May 16, 2018 at 04:23:47AM -0700, Matthew Wilcox wrote:
> > On Wed, May 16, 2018 at 07:43:34AM +0200, Christoph Hellwig wrote:
> > > this series tries to actually turn vm_fault_t into a type that can be
> > > typechecked and checks the fallout instead of sprinkling random
> > > annotations without context.
> > 
> > Yes, why should we have small tasks that newcomers can do when the mighty
> > Christoph Hellwig can swoop in and take over from them?  Seriously,
> > can't your talents find a better use than this?
> 
> I've spent less time on this than trying to argue to you and Souptick
> that these changes are only to get ignored and yelled at as an
> "asshole maintainer".  So yes, I could have done more productive things
> if you hadn't forced this escalation.

Perhaps you should try being less of an arsehole if you don't want to
get yelled at?  I don't mind when you're an arsehole towards me, but I
do mind when you're an arsehole towards newcomers.  How are we supposed
to attract and retain new maintainers when you're so rude?
