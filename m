Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 138076B0007
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 04:30:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z6-v6so3197116pgu.20
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:30:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j10-v6si2974389plg.396.2018.04.28.01.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 01:30:51 -0700 (PDT)
Date: Sat, 28 Apr 2018 01:30:49 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180428083049.GA31684@infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427071843.GB17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427071843.GB17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, Apr 27, 2018 at 09:18:43AM +0200, Michal Hocko wrote:
> > On Thu, Apr 26, 2018 at 09:54:06PM +0000, Luis R. Rodriguez wrote:
> > > In practice if you don't have a floppy device on x86, you don't need ZONE_DMA,
> > 
> > I call BS on that, and you actually explain later why it it BS due
> > to some drivers using it more explicitly.  But even more importantly
> > we have plenty driver using it through dma_alloc_* and a small DMA
> > mask, and they are in use - we actually had a 4.16 regression due to
> > them.
> 
> Well, but do we need a zone for that purpose? The idea was to actually
> replace the zone by a CMA pool (at least on x86). With the current
> implementation of the CMA we would move the range [0-16M] pfn range into 
> zone_movable so it can be used and we would get rid of all of the
> overhead each zone brings (a bit in page flags, kmalloc caches and who
> knows what else)

That wasn't clear in the mail.  But if we have anothr way to allocate
<16MB memory we don't need ZONE_DMA for the floppy driver either, so the
above conclusion is still wrong.

> -- 
> Michal Hocko
> SUSE Labs
---end quoted text---
