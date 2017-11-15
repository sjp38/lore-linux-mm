Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2B046B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 19:34:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d15so10985387pfl.0
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:34:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor616838pfu.120.2017.11.14.16.34.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 16:34:00 -0800 (PST)
Date: Tue, 14 Nov 2017 16:33:58 -0800
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: [kernel-hardening] Re: [PATCH v6 03/11] mm, x86: Add support for
 eXclusive Page Frame Ownership (XPFO)
Message-ID: <20171115003358.r3bsukc3vlbikjef@cisco>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
 <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi Dave,

On Mon, Nov 13, 2017 at 02:46:25PM -0800, Dave Hansen wrote:
> On 11/13/2017 02:20 PM, Dave Hansen wrote:
> > On 11/09/2017 05:09 PM, Tycho Andersen wrote:
> >> which I guess is from the additional flags in grow_dev_page() somewhere down
> >> the stack. Anyway... it seems this is a kernel allocation that's using
> >> MIGRATE_MOVABLE, so perhaps we need some more fine tuned heuristic than just
> >> all MOVABLE allocations are un-mapped via xpfo, and all the others are mapped.
> >>
> >> Do you have any ideas?
> > 
> > It still has to do a kmap() or kmap_atomic() to be able to access it.  I
> > thought you hooked into that.  Why isn't that path getting hit for these?
> 
> Oh, this looks to be accessing data mapped by a buffer_head.  It
> (rudely) accesses data via:
> 
> void set_bh_page(struct buffer_head *bh,
> ...
> 	bh->b_data = page_address(page) + offset;

Ah, yes. I guess there will be many bugs like this :). Anyway, I'll
try to cook up a patch.

Thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
