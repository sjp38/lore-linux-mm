Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 729286B000A
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 04:33:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z22so3476259pfi.7
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:33:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x64si3074854pff.196.2018.04.28.01.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 01:33:49 -0700 (PDT)
Date: Sat, 28 Apr 2018 01:33:47 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180428083347.GC31684@infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427071843.GB17484@dhcp22.suse.cz>
 <alpine.DEB.2.20.1804271103160.11686@nuc-kabylake>
 <20180427161813.GD8161@bombadil.infradead.org>
 <alpine.DEB.2.20.1804271136030.11686@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804271136030.11686@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, Apr 27, 2018 at 11:36:23AM -0500, Christopher Lameter wrote:
> On Fri, 27 Apr 2018, Matthew Wilcox wrote:
> 
> > Some devices have incredibly bogus hardware like 28 bit addressing
> > or 39 bit addressing.  We don't have a good way to allocate memory by
> > physical address other than than saying "GFP_DMA for anything less than
> > 32, GFP_DMA32 (or GFP_KERNEL on 32-bit) for anything less than 64 bit".
> >
> > Even CMA doesn't have a "cma_alloc_phys()".  Maybe that's the right place
> > to put such an allocation API.
> 
> The other way out of this would be to require a IOMMU?

Which on many systems doesn't exist.  And even if it exists might not
be usable.
