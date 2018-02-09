Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 649566B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:07:32 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b6so2277155plx.3
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:07:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r3-v6si1596357plo.432.2018.02.09.06.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 06:07:31 -0800 (PST)
Date: Fri, 9 Feb 2018 06:07:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180209140728.GC16666@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
 <20180209040814.GA23828@bombadil.infradead.org>
 <2DB8D5E5-0955-47CF-A142-09A5BA71DF70@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2DB8D5E5-0955-47CF-A142-09A5BA71DF70@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kai Heng Feng <kai.heng.feng@canonical.com>
Cc: Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 09, 2018 at 05:12:56PM +0800, Kai Heng Feng wrote:
> Hi Matthew,
> 
> > On Feb 9, 2018, at 12:08 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > Alternatively, try this.  It passes in GFP_DMA32 from vmalloc_32,
> > regardless of whether ZONE_DMA32 exists or not.  If ZONE_DMA32 doesn't
> > exist, then we clear it in __vmalloc_area_node(), after using it to
> > determine that we shouldn't set __GFP_HIGHMEM.
> 
> IIUC, I need to let drivers/media drivers start using vmalloc_32() with your
> patch, right?

Hopefully those that need to already are.  Otherwise they're broken
on 64-bit.  I do see several places already using vmalloc_32().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
