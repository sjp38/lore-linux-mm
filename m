Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47B9A6B026F
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:58:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u70so21121753pfa.2
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:58:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d12si15472525pgn.478.2017.11.15.06.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:58:39 -0800 (PST)
Date: Wed, 15 Nov 2017 06:58:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20171115145835.GB319@bombadil.infradead.org>
References: <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
 <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
 <20171115034430.GA24257@bombadil.infradead.org>
 <d1459463-061c-2aba-ff89-936284c138a3@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1459463-061c-2aba-ff89-936284c138a3@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On Tue, Nov 14, 2017 at 11:00:20PM -0800, Dave Hansen wrote:
> On 11/14/2017 07:44 PM, Matthew Wilcox wrote:
> > We don't need to kmap in order to access MOVABLE allocations.  kmap is
> > only needed for HIGHMEM allocations.  So there's nothing wrong with ext4
> > or set_bh_page().
> 
> Yeah, it's definitely not _buggy_.
> 
> Although, I do wonder what we should do about these for XPFO.  Should we
> just stick a kmap() in there and comment it?  What we really need is a
> mechanism to say "use this as a kernel page" and "stop using this as a
> kernel page".  kmap() does that... kinda.  It's not a perfect fit, but
> it's pretty close.

It'd be kind of funny if getting XPFO working better means improving
how well Linux runs on 32-bit machines with HIGHMEM.  I think there's
always going to be interest in those -- ARM developed 36 bit physmem
before biting the bullet and going to arm64.  Maybe OpenRISC will do
that next ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
